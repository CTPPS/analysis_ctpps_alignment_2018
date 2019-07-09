#include "config.h"
#include "stat.h"
#include "alignment_classes.h"

#include "TFile.h"
#include "TH1D.h"
#include "TH2D.h"
#include "TGraphErrors.h"
#include "TCanvas.h"
#include "TF1.h"
#include "TProfile.h"

#include <vector>
#include <string>

using namespace std;

//----------------------------------------------------------------------------------------------------

double FindMax(TF1 *ff)
{
	const double mu = ff->GetParameter(1);
	const double si = ff->GetParameter(2);

	// unreasonable fit?
	if (si > 25. || fabs(mu) > 100.)
		return 1E100;

	double x_max = 1E100;
	double y_max = -1E100;
	for (double x = mu - si; x <= mu + si; x += 0.001)
	{
		double y = ff->Eval(x);
		if (y > y_max)
		{
			x_max = x;
			y_max = y;
		}
	}

	return x_max;
}

//----------------------------------------------------------------------------------------------------

TF1 *ff_fit = new TF1("ff_fit", "[0] * exp(-(x-[1])*(x-[1])/2./[2]/[2]) + [3] + [4]*x");

TGraphErrors* BuildModeGraph(const TH2D *h2_y_vs_x, bool aligned, unsigned int rp)
{
	bool saveDetails = false;
	TDirectory *d_top = gDirectory;

	double y_max_fit = 10.;

	// 2018 settings
	if (rp ==  23) y_max_fit = 3.5 + ((aligned) ? 0. : 3.7);
	if (rp ==   3) y_max_fit = 4.5 + ((aligned) ? 0. : 3.8);
	if (rp == 103) y_max_fit = 5.5 + ((aligned) ? 0. : 3.2);
	if (rp == 123) y_max_fit = 4.8 + ((aligned) ? 0. : 3.1);

	TGraphErrors *g_y_mode_vs_x = new TGraphErrors();

	for (int bix = 1; bix <= h2_y_vs_x->GetNbinsX(); ++bix)
	{
		const double x = h2_y_vs_x->GetXaxis()->GetBinCenter(bix);
		const double x_unc = h2_y_vs_x->GetXaxis()->GetBinWidth(bix) / 2.;

		char buf[100];
		sprintf(buf, "h_y_x=%.3f", x);
		TH1D *h_y = h2_y_vs_x->ProjectionY(buf, bix, bix);

		if (h_y->GetEntries() < 300)
			continue;

		if (saveDetails)
		{
			sprintf(buf, "x=%.3f", x);
			gDirectory = d_top->mkdir(buf);
		}

		double con_max = -1.;
		double con_max_x = 0.;
		for (int biy = 1; biy < h_y->GetNbinsX(); ++biy)
		{
			if (h_y->GetBinContent(biy) > con_max)
			{
				con_max = h_y->GetBinContent(biy);
				con_max_x = h_y->GetBinCenter(biy);
			}
		}

		if (saveDetails)
			printf("x = %.3f\n", x);

		ff_fit->SetParameters(con_max, con_max_x, h_y->GetRMS() * 0.75, 0., 0.);
		ff_fit->FixParameter(4, 0.);

		if (saveDetails)
			printf("    init : mu = %.2f, si = %.2f\n", ff_fit->GetParameter(1), ff_fit->GetParameter(2));

		double x_min = 2., x_max = y_max_fit;
		if (aligned)
			x_min = -2., x_max = +3.;

		h_y->Fit(ff_fit, "Q", "", x_min, x_max);

		if (saveDetails)
			printf("    fit 1: mu = %.2f, si = %.2f\n", ff_fit->GetParameter(1), ff_fit->GetParameter(2));

		ff_fit->ReleaseParameter(4);
		double w = min(4., 2. * ff_fit->GetParameter(2));
		x_min = ff_fit->GetParameter(1) - w;
		x_max = min(y_max_fit, ff_fit->GetParameter(1) + w);
		if (saveDetails)
			printf("        x_min = %.3f, x_max = %.3f\n", x_min, x_max);
		h_y->Fit(ff_fit, "Q", "", x_min, x_max);

		if (saveDetails)
		{
			printf("    fit 2: mu = %.2f, si = %.2f\n", ff_fit->GetParameter(1), ff_fit->GetParameter(2));
			printf("        chi^2 = %.1f, ndf = %u, chi^2/ndf = %.1f\n", ff_fit->GetChisquare(), ff_fit->GetNDF(), ff_fit->GetChisquare() / ff_fit->GetNDF());
		}

		if (saveDetails)
			h_y->Write("h_y");

		double y_mode = FindMax(ff_fit);
		const double y_mode_fit_unc = ff_fit->GetParameter(2) / 10;
		const double y_mode_sys_unc = 0.030;
		double y_mode_unc = sqrt(y_mode_fit_unc*y_mode_fit_unc + y_mode_sys_unc*y_mode_sys_unc);

		const double chiSqThreshold = (aligned) ? 1000. : 50.;

		const bool valid = ! (fabs(y_mode_unc) > 5. || fabs(y_mode) > 20. || ff_fit->GetChisquare() / ff_fit->GetNDF() > chiSqThreshold);

		if (saveDetails)
			printf("    y_mode = %.3f, valid = %u\n", y_mode, valid);

		if (saveDetails)
		{
			TGraph *g_data = new TGraph();
			g_data->SetPoint(0, y_mode, y_mode_unc);
			g_data->SetPoint(1, ff_fit->GetChisquare(), ff_fit->GetNDF());
			g_data->SetPoint(2, valid, 0.);
			g_data->Write("g_data");
		}

		if (!valid)
			continue;

		int idx = g_y_mode_vs_x->GetN();
		g_y_mode_vs_x->SetPoint(idx, x, y_mode);
		g_y_mode_vs_x->SetPointError(idx, x_unc, y_mode_unc);
	}

	gDirectory = d_top;

	return g_y_mode_vs_x;
}

//----------------------------------------------------------------------------------------------------

int main()
{
	bool useAuxFits = true;

	// load config
	if (cfg.LoadFrom("config.py") != 0)
	{
		printf("ERROR: cannot load config.\n");
		return 1;
	}

	printf("-------------------- config ----------------------\n");
	cfg.Print(false);
	printf("--------------------------------------------------\n");

	// list of RPs and their settings
	struct RPData
	{
		string name;
		unsigned int id;
		string sectorName;
		double slope;
		double sh_x;
	};

	vector<RPData> rpData = {
		{ "L_2_F", 23,  "sector 45", (cfg.xangle == 160) ? 0.19 : 0.17, -42. },
		{ "L_1_F",  3,  "sector 45", (cfg.xangle == 160) ? 0.19 : 0.18, -3.6 },
		{ "R_1_F", 103, "sector 56", (cfg.xangle == 160) ? 0.40 : 0.34, -2.8 },
		{ "R_2_F", 123, "sector 56", (cfg.xangle == 160) ? 0.39 : 0.34, -41.9 }
	};

	// get input
	TFile *f_in = new TFile("distributions.root");

	TFile *f_in_aux = (useAuxFits) ? TFile::Open("../../../../../aux_fits/fits.root") : NULL;

	// ouput file
	TFile *f_out = new TFile("y_alignment.root", "recreate");

	// prepare results
	AlignmentResultsCollection results;

	TF1 *ff = new TF1("ff", "[0] + [1]*(x - [2])");
	TF1 *ff_sl_fix = new TF1("ff_sl_fix", "[0] + [1]*(x - [2])");

	// processing
	for (const auto &rpd : rpData)
	{
		printf("* %s\n", rpd.name.c_str());

		TDirectory *rp_dir = f_out->mkdir(rpd.name.c_str());
		gDirectory = rp_dir;
		
		TProfile *p_y_vs_x = (TProfile *) f_in->Get((rpd.sectorName + "/profiles/" + rpd.name + "/h_mean").c_str());

		TH2D *h2_y_vs_x = (TH2D *) f_in->Get((rpd.sectorName + "/after selection/" + rpd.name + "/h2_y_vs_x").c_str());

		if (p_y_vs_x == NULL || h2_y_vs_x == NULL)
		{
			printf("    cannot load data, skipping\n");
			continue;
		}

		TGraphErrors *g_y_cen_vs_x = BuildModeGraph(h2_y_vs_x, cfg.aligned, rpd.id);

		if (g_y_cen_vs_x->GetN() < 5)
			continue;

		const double x_min = cfg.alignment_y_ranges[rpd.id].x_min;
		const double x_max = cfg.alignment_y_ranges[rpd.id].x_max;

		printf("    x_min = %.3f, x_max = %.3f\n", x_min, x_max);

		double sh_x = rpd.sh_x;
		double slope = rpd.slope;

		if (useAuxFits)
		{
			char path[100];

			// to overcome the discrepancy in x-alignment results
			sprintf(path, "xangle_%u_beta_%.2f/%s/f_x_sh", 160, 0.30, rpd.name.c_str());
			sh_x = ((TF1*) f_in_aux->Get(path))->Eval(cfg.fill);

			sprintf(path, "xangle_%u_beta_%.2f/%s/f_y_tilt", cfg.xangle, cfg.beta, rpd.name.c_str());
			slope = ((TF1*) f_in_aux->Get(path))->Eval(cfg.fill);
		}

		printf("    sh_x = %.3f, slope = %.3f\n", sh_x, slope);

		ff->SetParameters(0., 0., 0.);
		ff->FixParameter(2, -sh_x);
		ff->SetLineColor(2);
		g_y_cen_vs_x->Fit(ff, "Q", "", x_min, x_max);

		const double a = ff->GetParameter(1), a_unc = ff->GetParError(1);
		const double b = ff->GetParameter(0), b_unc = ff->GetParError(0);

		results["y_alignment"][rpd.id] = AlignmentResult(0., 0., b, b_unc, 0., 0.);

		ff_sl_fix->SetParameters(0., 0., 0.);
		ff_sl_fix->FixParameter(1, slope);
		ff_sl_fix->FixParameter(2, -sh_x);
		ff_sl_fix->SetLineColor(4);
		g_y_cen_vs_x->Fit(ff_sl_fix, "Q+", "", x_min, x_max);

		const double b_fs = ff_sl_fix->GetParameter(0), b_fs_unc = ff_sl_fix->GetParError(0);

		results["y_alignment_sl_fix"][rpd.id] = AlignmentResult(0., 0., b_fs, b_fs_unc, 0., 0.);

		g_y_cen_vs_x->Write("g_y_cen_vs_x");

		TGraph *g_results = new TGraph();
		g_results->SetPoint(0, sh_x, 0.);
		g_results->SetPoint(1, a, a_unc);
		g_results->SetPoint(2, b, b_unc);
		g_results->SetPoint(3, b_fs, b_fs_unc);
		g_results->Write("g_results");
	}

	// write results
	results.Write("y_alignment.out");

	// clean up
	delete f_out;
	return 0;
}
