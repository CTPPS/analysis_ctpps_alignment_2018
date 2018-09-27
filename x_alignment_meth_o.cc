#include "config.h"
#include "stat.h"
#include "alignment_classes.h"

#include "TFile.h"
#include "TH1D.h"
#include "TGraphErrors.h"
#include "TCanvas.h"
#include "TF1.h"
#include "TProfile.h"
#include "TKey.h"
#include "TSpline.h"

#include <vector>
#include <string>

using namespace std;

bool debug_slope_fits = true;

//----------------------------------------------------------------------------------------------------

string ReplaceAll(const string &str, const string &from, const string &to)
{
	string output(str);

    size_t start_pos = 0;
    while ((start_pos = str.find(from, start_pos)) != string::npos)
	{
        output.replace(start_pos, from.length(), to);
        start_pos += to.length();
    }

    return output;
}

//----------------------------------------------------------------------------------------------------

TF1 *ff_pol1 = new TF1("ff_pol1", "[0] + [1]*x");
TF1 *ff_pol2 = new TF1("ff_pol2", "[0] + [1]*x + [2]*x*x");

//----------------------------------------------------------------------------------------------------

int FitProfile(TProfile *p, bool aligned, double &sl, double &sl_unc)
{
	if (p->GetEntries() < 100)
		return 1;

	for (int bi = 1; bi <= p->GetNbinsX(); ++bi)
	{
		if (p->GetBinEntries(bi) < 4)
		{
			p->SetBinContent(bi, 0.);
			p->SetBinError(bi, 0.);
		}
	}

	double x_min = 1., x_max = 7.;
	if (aligned) x_min = -3., x_max = +3.;

	ff_pol1->SetParameter(0., 0.);
	p->Fit(ff_pol1, "Q", "", x_min, x_max);

	sl = ff_pol1->GetParameter(1);
	sl_unc = ff_pol1->GetParError(1);

	return 0;
}

//----------------------------------------------------------------------------------------------------

TGraphErrors* BuildGraphFromDirectory(TDirectory *dir, bool aligned)
{
	TGraphErrors *g = new TGraphErrors();

	TIter next(dir->GetListOfKeys());
	TObject *o;
	while ((o = next()))
	{
		TKey *k = (TKey *) o;

		string name = k->GetName();
		size_t d = name.find("-");
		const double x_min = atof(name.substr(0, d).c_str());
		const double x_max = atof(name.substr(d+1).c_str());

		//printf("  %s, %.3f, %.3f\n", name.c_str(), x_min, x_max);

		TProfile *p = (TProfile *) k->ReadObj();

		double sl=0., sl_unc=0.;
		int fr = FitProfile(p, aligned, sl, sl_unc);
		if (fr != 0)
			continue;

		if (debug_slope_fits)
			p->Write(name.c_str());

		int idx = g->GetN();
		g->SetPoint(idx, (x_max + x_min)/2., sl);
		g->SetPointError(idx, (x_max - x_min)/2., sl_unc);
	}

	return g;
}

//----------------------------------------------------------------------------------------------------

int DoMatch(TGraphErrors *g_ref, TGraphErrors *g_test, const SelectionRange &range_ref, const SelectionRange &range_test,
		double sh_min, double sh_max, double &sh_best, double &sh_best_unc)
{
	// require minimal number of points
	if (g_ref->GetN() < 5 || g_test->GetN() < 5)
		return 1;

	// check actual range of test graph - TODO: needed ?
	double x_min_g_test = +1E100, x_max_g_test = -1E100;
	for (int i = 0; i < g_test->GetN(); ++i)
	{
		const double x = g_test->GetX()[i];
		x_min_g_test = min(x_min_g_test, x);
		x_max_g_test = max(x_max_g_test, x);
	}

	// make spline from g_ref
	TSpline3 *s_ref = new TSpline3("s_ref", g_ref->GetX(), g_ref->GetY(), g_ref->GetN());

	// book match-quality graphs
	TGraph *g_n_points = new TGraph(); g_n_points->SetName("g_n_points"); g_n_points->SetTitle(";sh;N");
	TGraph *g_chi_sq = new TGraph(); g_chi_sq->SetName("g_chi_sq"); g_chi_sq->SetTitle(";sh;S2");
	TGraph *g_chi_sq_norm = new TGraph(); g_chi_sq_norm->SetName("g_chi_sq_norm"); g_chi_sq_norm->SetTitle(";sh;S2 / N");

	// optimalisation variables
	double S2_norm_best = 1E100;

	double sh_step = 0.010;	// mm
	for (double sh = sh_min; sh <= sh_max; sh += sh_step)
	{
		// calculate chi^2
		int n_points = 0;
		double S2 = 0.;

		for (int i = 0; i < g_test->GetN(); ++i)
		{
			const double x_test = g_test->GetX()[i];
			const double y_test = g_test->GetY()[i];
			const double y_test_unc = g_test->GetErrorY(i);

			const double x_ref = x_test + sh;

			if (x_ref < range_ref.x_min || x_ref > range_ref.x_max || x_test < range_test.x_min || x_test > range_test.x_max)
				continue;

			const double y_ref = s_ref->Eval(x_ref);

			int js = -1, jg = -1;
			double xs = -1E100, xg = +1E100;
			for (int j = 0; j < g_ref->GetN(); ++j)
			{
				const double x = g_ref->GetX()[j];
				if (x < x_ref && x > xs)
				{
					xs = x;
					js = j;
				}
				if (x > x_ref && x < xg)
				{
					xg = x;
					jg = j;
				}
			}
			if (jg == -1)
				jg = js;

			const double y_ref_unc = ( g_ref->GetErrorY(js) + g_ref->GetErrorY(jg) ) / 2.;

			n_points++;
			const double S2_inc = pow(y_test - y_ref, 2.) / (y_ref_unc*y_ref_unc + y_test_unc*y_test_unc);
			S2 += S2_inc;
		}

		// update best result
		double S2_norm = S2 / n_points;

		if (S2_norm < S2_norm_best)
		{
			S2_norm_best = S2_norm;
			sh_best = sh;
		}

		// fill in graphs
		int idx = g_n_points->GetN();
		g_n_points->SetPoint(idx, sh, n_points);
		g_chi_sq->SetPoint(idx, sh, S2);
		g_chi_sq_norm->SetPoint(idx, sh, S2_norm);
	}

	// determine uncertainty
	double fit_range = 0.5;	// mm
	g_chi_sq->Fit(ff_pol2, "Q", "", sh_best - fit_range, sh_best + fit_range);
	sh_best_unc = 1. / sqrt(ff_pol2->GetParameter(2));

	// print results
	printf("        sh_best = (%.3f +- %.3f) mm\n", sh_best, sh_best_unc);

	// save graphs
	g_n_points->Write();
	g_chi_sq->Write();
	g_chi_sq_norm->Write();

	// save results
	TGraph *g_results = new TGraph();
	g_results->SetName("g_results");
	g_results->SetPoint(0, sh_best, sh_best_unc);
	g_results->SetPoint(1, range_ref.x_min, range_ref.x_max);
	g_results->SetPoint(2, range_test.x_min, range_test.x_max);
	g_results->Write();

	// save debug canvas
	TGraphErrors *g_test_shifted = new TGraphErrors(*g_test);
	for (int i = 0; i < g_test_shifted->GetN(); ++i)
	{
		g_test_shifted->GetX()[i] += sh_best;
	}

	TCanvas *c_cmp = new TCanvas("c_cmp");
	g_ref->SetLineColor(1);
	g_ref->Draw("apl");

	g_test->SetLineColor(6);
	g_test->Draw("pl");

	g_test_shifted->SetLineColor(2);
	g_test_shifted->Draw("pl");
	c_cmp->Write();

	// clean up
	delete s_ref;

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
	struct RPData
	{
		string name;
		unsigned int id;
		string sectorName;
		string position;
	};

	vector<RPData> rpData = {
		{ "L_2_F", 23,  "sector 45", "F" },
		{ "L_1_F", 3,   "sector 45", "N" },
		{ "R_1_F", 103, "sector 56", "N" },
		{ "R_2_F", 123, "sector 56", "F" }
	};

	// get input
	TFile *f_in = new TFile("distributions.root");

	// ouput file
	TFile *f_out = new TFile("x_alignment_meth_o.root", "recreate");

	// prepare results
	AlignmentResultsCollection results;

	// processing
	for (auto ref : cfg.matching_reference_datasets)
	{
		if (ref == "default")
		{
			char buf[100];
			sprintf(buf, "data/alig/fill_6228/xangle_%u/DS1", cfg.xangle);
			ref = buf;
		}

		printf("-------------------- reference dataset: %s\n", ref.c_str());

		const string &ref_tag = ReplaceAll(ref, "/", "_");
		TDirectory *ref_dir = f_out->mkdir(ref_tag.c_str());
	
		const string ref_path = "../../../../../" + ref;
		TFile *f_ref = TFile::Open((ref_path + "/distributions.root").c_str());

		Config cfg_ref;
		cfg_ref.LoadFrom(ref_path + "/config.py");

		for (const auto &rpd : rpData)
		{
			printf("* %s\n", rpd.name.c_str());

			// get input
			TDirectory *d_ref = (TDirectory *) f_ref->Get((rpd.sectorName + "/near_far/p_y_diffFN_vs_y_" + rpd.position + ", x slices").c_str());
			TDirectory *d_test = (TDirectory *) f_in->Get((rpd.sectorName + "/near_far/p_y_diffFN_vs_y_" + rpd.position + ", x slices").c_str());

			// prepare output directory
			TDirectory *rp_dir = ref_dir->mkdir(rpd.name.c_str());

			// build graphs for matching
			gDirectory = rp_dir->mkdir("fits_ref");
			TGraphErrors *g_ref = BuildGraphFromDirectory(d_ref, true);
			gDirectory = rp_dir->mkdir("fits_test");
			TGraphErrors *g_test = BuildGraphFromDirectory(d_test, false);

			gDirectory = rp_dir;
			g_ref->Write("g_ref");
			g_test->Write("g_test");

			// do match
			const auto &shift_range = cfg.matching_shift_ranges[rpd.id];
			double sh=0., sh_unc=0.;
			DoMatch(g_ref, g_test,
				cfg_ref.alignment_x_meth_o_ranges[rpd.id], cfg.alignment_x_meth_o_ranges[rpd.id],
				shift_range.x_min, shift_range.x_max, sh, sh_unc);

			// save results
			results[ref + ", method o"][rpd.id] = AlignmentResult(sh, sh_unc);
		}
		
		delete f_ref;
	}

	// write results
	FILE *f_results = fopen("x_alignment_meth_o.out", "w"); 
	results.Write(f_results);
	fclose(f_results);

	// clean up
	delete f_out;
	return 0;
}
