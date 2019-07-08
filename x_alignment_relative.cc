#include "config.h"
#include "stat.h"
#include "alignment_classes.h"

#include "TFile.h"
#include "TH1D.h"
#include "TGraph.h"
#include "TCanvas.h"
#include "TF1.h"
#include "TProfile.h"

#include <vector>
#include <string>

using namespace std;

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
	struct SectorData
	{
		string name;
		unsigned int id_N, id_F;
		string rp_N, rp_F;
		double slope;
		double sh_x_N;
	};

	vector<SectorData> sectorData = {
		{ "sector 45",   3,  23, "L_1_F", "L_2_F", (cfg.xangle == 160) ? +0.006 : +0.008, -3.6 },
		{ "sector 56", 103, 123, "R_1_F", "R_2_F", (cfg.xangle == 160) ? -0.015 : -0.012, -2.8 }
	};

	// get input
	TFile *f_in = new TFile("distributions.root");

	TFile *f_in_aux = (useAuxFits) ? TFile::Open("../../../../../aux_fits/fits.root") : NULL;

	// ouput file
	TFile *f_out = new TFile("x_alignment_relative.root", "recreate");

	// prepare results
	AlignmentResultsCollection results;

	TF1 *ff = new TF1("ff", "[0] + [1]*(x - [2])");
	TF1 *ff_sl_fix = new TF1("ff_sl_fix", "[0] + [1]*(x - [2])");

	// processing
	for (const auto &sd : sectorData)
	{
		printf("* %s\n", sd.name.c_str());

		TDirectory *sectorDir = f_out->mkdir(sd.name.c_str());
		gDirectory = sectorDir;
		
		TProfile *p_x_diffFN_vs_x_N = (TProfile *) f_in->Get((sd.name + "/near_far/p_x_diffFN_vs_x_N").c_str());

		if (p_x_diffFN_vs_x_N == NULL)
		{
			printf("    cannot load data, skipping\n");
			continue;
		}

		if (p_x_diffFN_vs_x_N->GetEntries() < 100)
		{
			printf("    insufficient data, skipping\n");
			continue;
		}

		const double x_min = cfg.alignment_x_relative_ranges[sd.id_N].x_min;
		const double x_max = cfg.alignment_x_relative_ranges[sd.id_N].x_max;

		printf("    x_min = %.3f, x_max = %.3f\n", x_min, x_max);

		double slope = sd.slope;
		double sh_x_N = sd.sh_x_N;

		if (useAuxFits)
		{
			char path[100];

			sprintf(path, "xangle_%u_beta_%.2f/%s/f_x_sh", 160, 0.30, sd.rp_N.c_str());
			sh_x_N = ((TF1*) f_in_aux->Get(path))->Eval(cfg.fill);

			sprintf(path, "xangle_%u_beta_%.2f/%s/f_x_slope", cfg.xangle, cfg.beta, sd.name.c_str());
			slope = ((TF1*) f_in_aux->Get(path))->Eval(cfg.fill);
		}

		ff->SetParameters(0., slope, 0.);
		ff->FixParameter(2, -sh_x_N);
		ff->SetLineColor(2);
		p_x_diffFN_vs_x_N->Fit(ff, "Q", "", x_min, x_max);

		const double a = ff->GetParameter(1), a_unc = ff->GetParError(1);
		const double b = ff->GetParameter(0), b_unc = ff->GetParError(0);

		results["x_alignment_relative"][sd.id_N] = AlignmentResult(+b/2., b_unc/2., 0., 0., 0., 0.);
		results["x_alignment_relative"][sd.id_F] = AlignmentResult(-b/2., b_unc/2., 0., 0., 0., 0.);

		ff_sl_fix->SetParameters(0., slope, 0.);
		ff_sl_fix->FixParameter(1, slope);
		ff_sl_fix->FixParameter(2, -sh_x_N);
		ff_sl_fix->SetLineColor(4);
		p_x_diffFN_vs_x_N->Fit(ff_sl_fix, "Q+", "", x_min, x_max);

		const double b_fs = ff_sl_fix->GetParameter(0), b_fs_unc = ff_sl_fix->GetParError(0);

		results["x_alignment_relative_sl_fix"][sd.id_N] = AlignmentResult(+b_fs/2., b_fs_unc/2., 0., 0., 0., 0.);
		results["x_alignment_relative_sl_fix"][sd.id_F] = AlignmentResult(-b_fs/2., b_fs_unc/2., 0., 0., 0., 0.);

		p_x_diffFN_vs_x_N->Write("p_x_diffFN_vs_x_N");

		TGraph *g_results = new TGraph();
		g_results->SetPoint(0, sh_x_N, 0.);
		g_results->SetPoint(1, a, a_unc);
		g_results->SetPoint(2, b, b_unc);
		g_results->SetPoint(3, b_fs, b_fs_unc);
		g_results->Write("g_results");
	}

	// write results
	results.Write("x_alignment_relative.out");

	// clean up
	delete f_out;
	return 0;
}
