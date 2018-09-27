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
		{ "L_2_F", 23,  "sector 45", 0.10, -42.05 },
		{ "L_1_F",  3,  "sector 45", 0.11, -3.7 },
		{ "R_1_F", 103, "sector 56", 0.18, -2.75 },
		{ "R_2_F", 123, "sector 56", 0.15, -42.05 }
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

		if (p_y_vs_x == NULL)
		{
			printf("    cannot load data, skipping\n");
			continue;
		}

		const double sh_x = rpd.sh_x;

		const double x_min = cfg.alignment_y_ranges[rpd.id].x_min;
		const double x_max = cfg.alignment_y_ranges[rpd.id].x_max;

		printf("    x_min = %.3f, x_max = %.3f\n", x_min, x_max);

		ff->SetParameters(0., 0., 0.);
		ff->FixParameter(2, -sh_x);
		ff->SetLineColor(2);
		p_y_vs_x->Fit(ff, "Q", "", x_min, x_max);

		const double a = ff->GetParameter(1), a_unc = ff->GetParError(1);
		const double b = ff->GetParameter(0), b_unc = ff->GetParError(0);

		results["y_alignment"][rpd.id] = AlignmentResult(0., 0., b, b_unc, 0., 0.);

		ff_sl_fix->SetParameters(0., 0., 0.);
		ff_sl_fix->FixParameter(1, rpd.slope);
		ff_sl_fix->FixParameter(2, -sh_x);
		ff_sl_fix->SetLineColor(4);
		p_y_vs_x->Fit(ff_sl_fix, "Q+", "", x_min, x_max);

		const double b_fs = ff_sl_fix->GetParameter(0), b_fs_unc = ff_sl_fix->GetParError(0);

		results["y_alignment_sl_fix"][rpd.id] = AlignmentResult(0., 0., b_fs, b_fs_unc, 0., 0.);

		p_y_vs_x->Write("p_y_vs_x");

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
