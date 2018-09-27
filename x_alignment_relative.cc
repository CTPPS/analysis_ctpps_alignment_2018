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
	struct SectorData
	{
		string name;
		unsigned int id_N, id_F;
		double slope;
	};

	vector<SectorData> sectorData = {
		{ "sector 45", 3, 23, +0.008 },
		{ "sector 56", 103, 123, -0.012 }
	};

	// get input
	TFile *f_in = new TFile("distributions.root");

	// ouput file
	TFile *f_out = new TFile("x_alignment_relative.root", "recreate");

	// prepare results
	AlignmentResultsCollection results;

	TF1 *ff = new TF1("ff", "[0] + [1]*x");
	TF1 *ff_sl_fix = new TF1("ff_sl_fix", "[0] + [1]*x");

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

		const double x_min = cfg.alignment_x_relative_ranges[sd.id_N].x_min;
		const double x_max = cfg.alignment_x_relative_ranges[sd.id_N].x_max;

		printf("    x_min = %.3f, x_max = %.3f\n", x_min, x_max);

		ff->SetParameters(0., sd.slope);
		ff->SetLineColor(2);
		p_x_diffFN_vs_x_N->Fit(ff, "Q", "", x_min, x_max);

		const double a = ff->GetParameter(1), a_unc = ff->GetParError(1);
		const double b = ff->GetParameter(0), b_unc = ff->GetParError(0);

		results["x_alignment_relative"][sd.id_N] = AlignmentResult(0., 0., +b/2., b_unc/2., 0., 0.);
		results["x_alignment_relative"][sd.id_F] = AlignmentResult(0., 0., -b/2., b_unc/2., 0., 0.);

		ff_sl_fix->SetParameters(0., sd.slope);
		ff_sl_fix->FixParameter(1, sd.slope);
		ff_sl_fix->SetLineColor(4);
		p_x_diffFN_vs_x_N->Fit(ff_sl_fix, "Q+", "", x_min, x_max);

		const double b_fs = ff_sl_fix->GetParameter(0), b_fs_unc = ff_sl_fix->GetParError(0);

		results["x_alignment_relative_sl_fix"][sd.id_N] = AlignmentResult(0., 0., +b_fs/2., b_fs_unc/2., 0., 0.);
		results["x_alignment_relative_sl_fix"][sd.id_F] = AlignmentResult(0., 0., -b_fs/2., b_fs_unc/2., 0., 0.);

		p_x_diffFN_vs_x_N->Write("p_x_diffFN_vs_x_N");

		TGraph *g_results = new TGraph();
		g_results->SetPoint(0, a, a_unc);
		g_results->SetPoint(1, b, b_unc);
		g_results->SetPoint(2, b_fs, b_fs_unc);
		g_results->Write("g_results");
	}

	// write results
	results.Write("x_alignment_relative.out");

	// clean up
	delete f_out;
	return 0;
}
