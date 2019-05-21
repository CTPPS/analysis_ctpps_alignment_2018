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

double GetP3InitValue(const string &sector, const string &rp, unsigned int fill)
{
	if (fill >= 6583 && fill <= 6778)
	{
		if (sector == "sector 45" && rp == "F") return 3.4;
		if (sector == "sector 45" && rp == "N") return 4.7;
		if (sector == "sector 56" && rp == "N") return 4.5;
		if (sector == "sector 56" && rp == "F") return 3.3;
	}

	if (fill >= 6843 && fill <= 7145)
	{
		if (sector == "sector 45" && rp == "F") return 4.0;
		if (sector == "sector 45" && rp == "N") return 4.0;
		if (sector == "sector 56" && rp == "N") return 4.1;
		if (sector == "sector 56" && rp == "F") return 3.7;
	}

	if (fill >= 7213 && fill <= 7334)
	{
		if (sector == "sector 45" && rp == "F") return 4.5;
		if (sector == "sector 45" && rp == "N") return 3.5;
		if (sector == "sector 56" && rp == "N") return 3.7;
		if (sector == "sector 56" && rp == "F") return 4.2;
	}

	return 0;
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
	struct ArmData
	{
		string name;
		unsigned int rp_id_N;
		unsigned int rp_id_F;
		double corr_N;
		double corr_F;
	};

	vector<ArmData> armData = {
		{ "sector 45", 3, 23, 0., 0. },
		{ "sector 56", 103, 123, 0., 0. },
	};

	// get input
	TFile *f_in = new TFile("distributions.root");

	// ouput file
	TFile *f_out = new TFile("y_alignment_alt.root", "recreate");

	// prepare results
	AlignmentResultsCollection results;

	TF1 *ff = new TF1("ff", "[0] + [1]*(x - [3]) + [2]*(TMath::Erf( (x-[3])/[4] ))");

	// processing
	for (const auto &ad : armData)
	{
		TDirectory *arm_dir = f_out->mkdir(ad.name.c_str());

		bool fit_valid_N = false, fit_valid_F = false;
		
		double y0_N = 0., y0_N_unc = 0., yd_N = 0., yd_N_unc = 0.;
		double y0_F = 0., y0_F_unc = 0., yd_F = 0., yd_F_unc = 0.;

		// make fits for each RP
		for (const string rp : { "N", "F"} )
		{
			TDirectory *rp_dir = arm_dir->mkdir(rp.c_str());
			gDirectory = rp_dir;

			printf("* %s, rp %s\n", ad.name.c_str(), rp.c_str());
			
			// load input
			TProfile *p_y_diffFN_vs_y = (TProfile *) f_in->Get((ad.name + "/near_far/p_y_diffFN_vs_y_" + rp).c_str());

			if (p_y_diffFN_vs_y == NULL)
			{
				printf("    cannot load data, skipping\n");
				continue;
			}

			if (p_y_diffFN_vs_y->GetEntries() < 100)
			{
				printf("    insufficient data, skipping\n");
				continue;
			}

			// do fits
			int cbi = p_y_diffFN_vs_y->GetXaxis()->FindBin(3.5);

			double p0_init = p_y_diffFN_vs_y->GetBinContent(cbi);
			double p1_init = 0.05;
			double p2_init = 0.05;
			double p3_init = GetP3InitValue(ad.name, rp, cfg.fill);
			double p4_init = (ad.name == "sector 45") ? 1.0 : 2.0;

			ff->SetParameters(p0_init, p1_init, p2_init, p3_init, p4_init);

			double x_min, x_max;
			double x_range = (ad.name == "sector 45") ? 2.5 : 3.0;

			x_min = ff->GetParameter(3.) - x_range; x_max = ff->GetParameter(3.) + x_range;
			ff->FixParameter(3, p3_init);
			p_y_diffFN_vs_y->Fit(ff, "Q", "", x_min, x_max);
			ff->ReleaseParameter(3);
			p_y_diffFN_vs_y->Fit(ff, "Q", "", x_min, x_max);

			x_min = ff->GetParameter(3.) - x_range; x_max = ff->GetParameter(3.) + x_range;
			p_y_diffFN_vs_y->Fit(ff, "Q", "", x_min, x_max);
			p_y_diffFN_vs_y->Fit(ff, "Q", "", x_min, x_max);

			p_y_diffFN_vs_y->Write("p_y_diffFN_vs_y");

			if (rp == "N") fit_valid_N = true, y0_N = ff->GetParameter(3), y0_N_unc = ff->GetParError(3), yd_N = ff->GetParameter(0), yd_N_unc = ff->GetParError(0);
			if (rp == "F") fit_valid_F = true, y0_F = ff->GetParameter(3), y0_F_unc = ff->GetParError(3), yd_F = ff->GetParameter(0), yd_F_unc = ff->GetParError(0);
		}

		// stop if any fit is not valid
		if (!fit_valid_N || !fit_valid_F)
			continue;

		// combine fit results
		printf("* %s\n", ad.name.c_str());

		printf("    N: y0 = %.3f +- %.3f, yd = %.3f +- %.3f\n", y0_N, y0_N_unc, yd_N, yd_N_unc);
		printf("    F: y0 = %.3f +- %.3f, yd = %.3f +- %.3f\n", y0_F, y0_F_unc, yd_F, yd_F_unc);
		printf("    F - N: y0 = %.3f\n", y0_F - y0_N);

		const double c = ((yd_N + yd_F) / 2. - (y0_F - y0_N) ) / 2.;
		const double sh_y_N = y0_N - c + ad.corr_N;
		const double sh_y_F = y0_F + c + ad.corr_F;

		printf("    sh_y_N = %.3f, sh_y_F = %.3f\n", sh_y_N, sh_y_F);

		results["y_alignment_alt"][ad.rp_id_N] = AlignmentResult(0., 0., sh_y_N, y0_N_unc, 0., 0.);
		results["y_alignment_alt"][ad.rp_id_F] = AlignmentResult(0., 0., sh_y_F, y0_F_unc, 0., 0.);

		// save combined results
		for (const string rp : { "N", "F"} )
		{
			TDirectory *rp_dir = (TDirectory *) arm_dir->Get(rp.c_str());
			gDirectory = rp_dir;

			TGraph *g_results = new TGraph();

			const double y0 = (rp == "N") ? y0_N : y0_F;
			const double y0_unc = (rp == "N") ? y0_N_unc : y0_F_unc;
			const double yd = (rp == "N") ? yd_N : yd_F;
			const double yd_unc = (rp == "N") ? yd_N_unc : yd_F_unc;
			const double sh_y = (rp == "N") ? sh_y_N : sh_y_F;

			g_results->SetPoint(0, y0, y0_unc);
			g_results->SetPoint(1, yd, yd_unc);
			g_results->SetPoint(2, sh_y, y0_unc);

			g_results->Write("g_results");
		}
	}

	// write results
	results.Write("y_alignment_alt.out");

	// clean up
	delete f_out;
	return 0;
}
