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

TF1 *ff_gauss = new TF1("ff_gauss", "[0] * exp(-(x-[1])*(x-[1])/2./[2]/[2]) + [3]");

TGraphErrors* BuildModeGraph(const TH2D *h2_y_vs_x)
{
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

		ff_gauss->SetParameters(con_max, con_max_x, h_y->GetRMS(), 0.);

		h_y->Fit(ff_gauss, "Q", "", 3., +8.);
		double w = min(2., 2. * ff_gauss->GetParameter(2));
		h_y->Fit(ff_gauss, "Q", "", ff_gauss->GetParameter(1) - w, ff_gauss->GetParameter(1) + w);
		/*
		n_si = 2.;
		h_y->Fit(ff_gauss, "Q", "", ff_gauss->GetParameter(1) - n_si*ff_gauss->GetParameter(2), ff_gauss->GetParameter(1) + n_si*ff_gauss->GetParameter(2));
		n_si = 1.5;
		h_y->Fit(ff_gauss, "Q", "", ff_gauss->GetParameter(1) - n_si*ff_gauss->GetParameter(2), ff_gauss->GetParameter(1) + n_si*ff_gauss->GetParameter(2));
		n_si = 1.5;
		h_y->Fit(ff_gauss, "Q", "", ff_gauss->GetParameter(1) - n_si*ff_gauss->GetParameter(2), ff_gauss->GetParameter(1) + n_si*ff_gauss->GetParameter(2));
		*/

		//h_y->Write();

		//printf("x = %.3f mm, %f/%i = %.2f\n", x, ff_gauss->GetChisquare(), ff_gauss->GetNDF(), ff_gauss->GetChisquare() / ff_gauss->GetNDF());

		double y_mode = ff_gauss->GetParameter(1);
		double y_mode_unc = ff_gauss->GetParError(1);

		if (fabs(y_mode_unc) > 1. || ff_gauss->GetChisquare() / ff_gauss->GetNDF() > 5.)
			continue;

		int idx = g_y_mode_vs_x->GetN();
		g_y_mode_vs_x->SetPoint(idx, x, y_mode);
		g_y_mode_vs_x->SetPointError(idx, x_unc, y_mode_unc);
	}

	return g_y_mode_vs_x;
}

//----------------------------------------------------------------------------------------------------

int main()
{
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

	// TODO: update sh_x
	// TODO: update slopes, make them cfg.xangle dependent
	vector<RPData> rpData = {
		{ "L_2_F", 23,  "sector 45", 0.18, -42. },
		{ "L_1_F",  3,  "sector 45", 0.18, -3.6 },
		{ "R_1_F", 103, "sector 56", 0.24, -2.8 },
		{ "R_2_F", 123, "sector 56", 0.22, -41.9 }
	};

	// get input
	TFile *f_in = new TFile("distributions.root");

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

		TGraphErrors *g_y_cen_vs_x = BuildModeGraph(h2_y_vs_x);

		if (g_y_cen_vs_x->GetN() < 5)
			continue;

		const double sh_x = rpd.sh_x;

		const double x_min = cfg.alignment_y_ranges[rpd.id].x_min;
		const double x_max = cfg.alignment_y_ranges[rpd.id].x_max;

		printf("    x_min = %.3f, x_max = %.3f\n", x_min, x_max);

		ff->SetParameters(0., 0., 0.);
		ff->FixParameter(2, -sh_x);
		ff->SetLineColor(2);
		g_y_cen_vs_x->Fit(ff, "Q", "", x_min, x_max);

		const double a = ff->GetParameter(1), a_unc = ff->GetParError(1);
		const double b = ff->GetParameter(0), b_unc = ff->GetParError(0);

		results["y_alignment"][rpd.id] = AlignmentResult(0., 0., b, b_unc, 0., 0.);

		ff_sl_fix->SetParameters(0., 0., 0.);
		ff_sl_fix->FixParameter(1, rpd.slope);
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
