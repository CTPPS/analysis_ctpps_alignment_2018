#include "../alignment_classes.h"
#include "../export/fills_runs.h"

#include "TGraphErrors.h"
#include "TFile.h"
#include "TF1.h"

using namespace std;

//----------------------------------------------------------------------------------------------------

struct RPGraphs
{
	TGraphErrors *g_x_sh = NULL;
	TGraphErrors *g_y_tilt;

	TF1 *f_x_sh = NULL;
	TF1 *f_y_tilt = NULL;

	void Init()
	{
		if (g_x_sh)
			return;

		g_x_sh = new TGraphErrors();
		g_y_tilt = new TGraphErrors();
	}

	void Write() const
	{
		g_x_sh->Write("g_x_sh");
		if (f_x_sh)
			f_x_sh->Write("f_x_sh");

		g_y_tilt->Write("g_y_tilt");
		if (f_y_tilt)
			f_y_tilt->Write("f_y_tilt");
	}
};

//----------------------------------------------------------------------------------------------------

int main()
{
	// initialisation
	InitFillsRuns(false);
	//PrintFillRunMapping();

	string topDir = "../data/phys-version1";

	vector<string> cfgs = {
		"xangle_160_beta_0.30",
		"xangle_130_beta_0.30",
		"xangle_130_beta_0.25",
	};

	string dataset = "ALL";

	vector<string> rps = {
		"L_2_F",
		"L_1_F",
		"R_1_F",
		"R_2_F",
	};

	// prepare output
	TFile *f_out = TFile::Open("fits.root", "recreate");

	// loop over configurations
	for (const auto &cfg : cfgs)
	{
		TDirectory *d_cfg = f_out->mkdir(cfg.c_str());

		// collect data (build fill-dependent graphs)
		map<string, RPGraphs> rpGraphs;

		for (const auto &fill : fills)
		{
			//printf("----------------------\n");
			printf("fill = %u\n", fill);

			// path base
			char buf[100];
			sprintf(buf, "%s/fill_%u", topDir.c_str(), fill);

			// try to get input
			string dir = string(buf) + "/" + cfg + "/" + dataset;

			TFile *f_in_x_sh = TFile::Open((dir + "/x_alignment_meth_o.root").c_str());
			string ref_x_sh = "data_alig-version1_fill_6554_" + cfg + "_DS1";

			TFile *f_in_y_tilt = TFile::Open((dir + "/y_alignment.root").c_str());

			//printf("%p, %p\n", f_in_x_sh, f_in_y_tilt);

			for (const auto &rp : rps)
			{
				auto &g = rpGraphs[rp];
				g.Init();

				if (f_in_x_sh)
				{
					TGraph *g_results = (TGraph *) f_in_x_sh->Get((ref_x_sh + "/" + rp + "/g_results").c_str());

					//printf("* %s, %p\n", rp.c_str(), g_results);

					if (g_results)
					{
						const double x_sh = g_results->GetX()[0];
						const double x_sh_unc = g_results->GetY()[0];

						int idx = g.g_x_sh->GetN();
						g.g_x_sh->SetPoint(idx, fill, x_sh);
						g.g_x_sh->SetPointError(idx, 0., x_sh_unc);
					}
				}

				if (f_in_y_tilt)
				{
					TGraph *g_results = (TGraph *) f_in_y_tilt->Get((rp + "/g_results").c_str());

					if (g_results)
					{
						const double y_tilt = g_results->GetX()[1];
						const double y_tilt_unc = g_results->GetY()[1];

						if (y_tilt > 0.1 && y_tilt < 0.6)
						{
							int idx = g.g_y_tilt->GetN();
							g.g_y_tilt->SetPoint(idx, fill, y_tilt);
							g.g_y_tilt->SetPointError(idx, 0., y_tilt_unc);
						}
					}
				}
			}

			if (f_in_x_sh)
				delete f_in_x_sh;

			if (f_in_y_tilt)
				delete f_in_y_tilt;
		}

		// fit graphs
		for (auto &g : rpGraphs)
		{
			g.second.f_x_sh = new TF1("", "([0] + [1]*x) + (x > 6670) * ([2] + [3]*x) + (x > 6800) * ([4] + [5]*x) + (x > 6980) * ([6] + [7]*x)  + (x > 7180) * ([8] + [9]*x)");
			g.second.g_x_sh->Fit(g.second.f_x_sh, "Q");

			g.second.f_y_tilt = new TF1("", "[0] + (x > 6854) * ([1]) + (x > 7213) * ([2])");
			g.second.g_y_tilt->Fit(g.second.f_y_tilt, "Q");
		}

		// save fits
		for (auto &p : rpGraphs)
		{
			gDirectory = d_cfg->mkdir(p.first.c_str());
			p.second.Write();
		}
	}

	// clean up
	delete f_out;
	return 0;
}
