#include "config.h"
#include "stat.h"

#include "TFile.h"
#include "TH1D.h"
#include "TH2D.h"
#include "TProfile.h"
#include "TF1.h"
#include "TGraph.h"
#include "TCanvas.h"

#include "DataFormats/FWLite/interface/Handle.h"
#include "DataFormats/FWLite/interface/ChainEvent.h"

#include "DataFormats/CTPPSDetId/interface/TotemRPDetId.h"
#include "DataFormats/CTPPSReco/interface/CTPPSLocalTrackLite.h"

#include <vector>
#include <string>

using namespace std;
using namespace edm;

//----------------------------------------------------------------------------------------------------

struct Profile
{
	string name;
	TH2D *h;

	vector<Stat> st;

	Profile(const string &_name, TH2D *_h) : name(_name), h(_h), st(h->GetNbinsX(), Stat(1))
	{
	}

	void Fill(double x, double y)
	{
		int bi = h->GetXaxis()->FindBin(x);

		if (bi < 1 || bi > h->GetNbinsX())
			return;

		int vi = bi - 1;
		st[vi].Fill(y);
	}

	void Write()
	{
		TDirectory *dir_top = gDirectory;	
		gDirectory = gDirectory->mkdir(name.c_str());

		int bins = h->GetXaxis()->GetNbins();
		double x_min = h->GetXaxis()->GetXmin();
		double x_max = h->GetXaxis()->GetXmax();

		TH1D *h_entries = new TH1D("h_entries", ";x", bins, x_min, x_max);
		TH1D *h_mean = new TH1D("h_mean", ";x", bins, x_min, x_max);
		TH1D *h_stddev = new TH1D("h_stddev", ";x", bins, x_min, x_max);

		for (int bi = 1; bi <= bins; ++bi)
		{
			int vi = bi - 1;

			h_entries->SetBinContent(bi, st[vi].GetEntries());

			h_mean->SetBinContent(bi, st[vi].GetMean(0));
			h_mean->SetBinError(bi, st[vi].GetMeanUnc(0));

			h_stddev->SetBinContent(bi, st[vi].GetStdDev(0));
			h_stddev->SetBinError(bi, st[vi].GetStdDevUncGauss(0));
		}

		h_entries->Write();
		h_mean->Write();
		h_stddev->Write();

		gDirectory = dir_top;
	}
};

//----------------------------------------------------------------------------------------------------

void WriteCutPlot(TH2D *h, double a, double c, double si, const string &label)
{
	TCanvas *canvas = new TCanvas();
	canvas->SetName(label.c_str());
	canvas->SetLogz(1);

	h->Draw("colz");

	double x_min = -30.;
	double x_max = +30.;

	TGraph *g_up = new TGraph();
	g_up->SetName("g_up");
	g_up->SetPoint(0, x_min, -a*x_min - c + cfg.n_si * si);
	g_up->SetPoint(1, x_max, -a*x_max - c + cfg.n_si * si);
	g_up->SetLineColor(1);
	g_up->Draw("l");

	TGraph *g_down = new TGraph();
	g_down->SetName("g_down");
	g_down->SetPoint(0, x_min, -a*x_min - c - cfg.n_si * si);
	g_down->SetPoint(1, x_max, -a*x_max - c - cfg.n_si * si);
	g_down->SetLineColor(1);
	g_down->Draw("l");

	canvas->Write();
}

//----------------------------------------------------------------------------------------------------
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
	cfg.Print(true);
	printf("--------------------------------------------------\n");

	// setup input
	fwlite::ChainEvent ev(cfg.input_files);

	printf("* events in input chain: %llu\n", ev.size());

	// ouput file
	TFile *f_out = new TFile("distributions.root", "recreate");

	// book histograms
	const double bin_size_x = 142.3314E-3; // mm
	const unsigned int n_bins_x = 210;

	const double pixel_x_offset = (cfg.aligned) ? 0. : 0.;

	const double x_min_pix = pixel_x_offset, x_max_pix = pixel_x_offset + n_bins_x * bin_size_x;
	const double x_min_str = 0., x_max_str = n_bins_x * bin_size_x;

	const unsigned int n_bins_y = 400;
	const double y_min = -20., y_max = +20.;

	TH2D *h2_y_vs_x_L_2_F_no_sel = new TH2D("h2_y_vs_x_L_2_F_no_sel", ";x;y", n_bins_x, x_min_pix, x_max_pix, n_bins_y, y_min, y_max);
	TH2D *h2_y_vs_x_L_1_F_no_sel = new TH2D("h2_y_vs_x_L_1_F_no_sel", ";x;y", n_bins_x, x_min_str, x_max_str, n_bins_y, y_min, y_max);
	TH2D *h2_y_vs_x_R_1_F_no_sel = new TH2D("h2_y_vs_x_R_1_F_no_sel", ";x;y", n_bins_x, x_min_str, x_max_str, n_bins_y, y_min, y_max);
	TH2D *h2_y_vs_x_R_2_F_no_sel = new TH2D("h2_y_vs_x_R_2_F_no_sel", ";x;y", n_bins_x, x_min_pix, x_max_pix, n_bins_y, y_min, y_max);

	TH2D *h2_x_L_2_F_vs_x_L_1_F_before = new TH2D("h2_x_L_2_F_vs_x_L_1_F_before", ";x_L_1_F;x_L_2_F", n_bins_x, x_min_str, x_max_str, n_bins_x, x_min_pix, x_max_pix);
	TH2D *h2_x_L_2_F_vs_x_L_1_F_after = new TH2D("h2_x_L_2_F_vs_x_L_1_F_after", ";x_L_1_F;x_L_2_F", n_bins_x, x_min_str, x_max_str, n_bins_x, x_min_pix, x_max_pix);
	TProfile *p_x_L_2_F_vs_x_L_1_F_after = new TProfile("p_x_L_2_F_vs_x_L_1_F_after", ";x_L_1_F;x_L_2_F", n_bins_x, x_min_str, x_max_str);
	TH1D *h_q_cut1_before = new TH1D("h_q_cut1_before", ";cq1", 400, -2., 2.); h_q_cut1_before->SetLineColor(2);
	TH1D *h_q_cut1_after = new TH1D("h_q_cut1_after", ";cq1", 400, -2., 2.); h_q_cut1_after->SetLineColor(4);

	TH2D *h2_x_R_2_F_vs_x_R_1_F_before = new TH2D("h2_x_R_2_F_vs_x_R_1_F_before", ";x_R_1_F;x_R_2_F", n_bins_x, x_min_str, x_max_str, n_bins_x, x_min_pix, x_max_pix);
	TH2D *h2_x_R_2_F_vs_x_R_1_F_after = new TH2D("h2_x_R_2_F_vs_x_R_1_F_after", ";x_R_1_F;x_R_2_F", n_bins_x, x_min_str, x_max_str, n_bins_x, x_min_pix, x_max_pix);
	TProfile *p_x_R_2_F_vs_x_R_1_F_after = new TProfile("p_x_R_2_F_vs_x_R_1_F_after", ";x_R_1_F;x_R_2_F", n_bins_x, x_min_str, x_max_str);
	TH1D *h_q_cut2_before = new TH1D("h_q_cut2_before", ";cq2", 400, -2., 2.); h_q_cut2_before->SetLineColor(2);
	TH1D *h_q_cut2_after = new TH1D("h_q_cut2_after", ";cq2", 400, -2., 2.); h_q_cut2_after->SetLineColor(4);

	TH2D *h2_y_L_2_F_vs_y_L_1_F_before = new TH2D("h2_y_L_2_F_vs_y_L_1_F_before", ";y_L_1_F;y_L_2_F", 100, -10., +10., 100, -10., +10.);
	TH2D *h2_y_L_2_F_vs_y_L_1_F_after = new TH2D("h2_y_L_2_F_vs_y_L_1_F_after", ";y_L_1_F;y_L_2_F", 100, -10., +10., 100, -10., +10.);
	TProfile *p_y_L_2_F_vs_y_L_1_F_after = new TProfile("p_y_L_2_F_vs_y_L_1_F_after", ";y_L_1_F;y_L_2_F", 100, -10., +10.);
	TH1D *h_q_cut3_before = new TH1D("h_q_cut3_before", ";cq3", 400, -2., 2.); h_q_cut3_before->SetLineColor(2);
	TH1D *h_q_cut3_after = new TH1D("h_q_cut3_after", ";cq3", 400, -2., 2.); h_q_cut3_after->SetLineColor(4);

	TH2D *h2_y_R_2_F_vs_y_R_1_F_before = new TH2D("h2_y_R_2_F_vs_y_R_1_F_before", ";y_R_1_F;y_R_2_F", 100, -10., +10., 100, -10., +10.);
	TH2D *h2_y_R_2_F_vs_y_R_1_F_after = new TH2D("h2_y_R_2_F_vs_y_R_1_F_after", ";y_R_1_F;y_R_2_F", 100, -10., +10., 100, -10., +10.);
	TProfile *p_y_R_2_F_vs_y_R_1_F_after = new TProfile("p_y_R_2_F_vs_y_R_1_F_after", ";y_R_1_F;y_R_2_F", 100, -10., +10.);
	TH1D *h_q_cut4_before = new TH1D("h_q_cut4_before", ";cq4", 400, -2., 2.); h_q_cut4_before->SetLineColor(2);
	TH1D *h_q_cut4_after = new TH1D("h_q_cut4_after", ";cq4", 400, -2., 2.); h_q_cut4_after->SetLineColor(4);

	TGraph *g_y_vs_x_L_2_F_sel = new TGraph(); g_y_vs_x_L_2_F_sel->SetName("g_y_vs_x_L_2_F_sel"); g_y_vs_x_L_2_F_sel->SetTitle(";x;y");
	TGraph *g_y_vs_x_L_1_F_sel = new TGraph(); g_y_vs_x_L_1_F_sel->SetName("g_y_vs_x_L_1_F_sel"); g_y_vs_x_L_1_F_sel->SetTitle(";x;y");
	TGraph *g_y_vs_x_R_1_F_sel = new TGraph(); g_y_vs_x_R_1_F_sel->SetName("g_y_vs_x_R_1_F_sel"); g_y_vs_x_R_1_F_sel->SetTitle(";x;y");
	TGraph *g_y_vs_x_R_2_F_sel = new TGraph(); g_y_vs_x_R_2_F_sel->SetName("g_y_vs_x_R_2_F_sel"); g_y_vs_x_R_2_F_sel->SetTitle(";x;y");

	TH2D *h2_y_vs_x_L_2_F_sel = new TH2D(*h2_y_vs_x_L_2_F_no_sel); h2_y_vs_x_L_2_F_sel->SetName("h2_y_vs_x_L_2_F_sel");
	TH2D *h2_y_vs_x_L_1_F_sel = new TH2D(*h2_y_vs_x_L_1_F_no_sel); h2_y_vs_x_L_1_F_sel->SetName("h2_y_vs_x_L_1_F_sel");
	TH2D *h2_y_vs_x_R_1_F_sel = new TH2D(*h2_y_vs_x_R_1_F_no_sel); h2_y_vs_x_R_1_F_sel->SetName("h2_y_vs_x_R_1_F_sel");
	TH2D *h2_y_vs_x_R_2_F_sel = new TH2D(*h2_y_vs_x_R_2_F_no_sel); h2_y_vs_x_R_2_F_sel->SetName("h2_y_vs_x_R_2_F_sel");

	Profile p_y_vs_x_L_2_F_sel("L_2_F", h2_y_vs_x_L_2_F_sel);
	Profile p_y_vs_x_L_1_F_sel("L_1_F", h2_y_vs_x_L_1_F_sel);
	Profile p_y_vs_x_R_1_F_sel("R_1_F", h2_y_vs_x_R_1_F_sel);
	Profile p_y_vs_x_R_2_F_sel("R_2_F", h2_y_vs_x_R_2_F_sel);

	// loop over the chain entries
	unsigned long int ev_count = 0;
	unsigned long int tr_sel_count = 0;
	for (ev.toBegin(); ! ev.atEnd(); ++ev)
	{
		ev_count++;

		// TODO: comment out
		if (tr_sel_count > 1000000)
			break;

		// default track data
		CTPPSLocalTrackLite tr_L_2_F;
		CTPPSLocalTrackLite tr_L_1_F;
		CTPPSLocalTrackLite tr_R_1_F;
		CTPPSLocalTrackLite tr_R_2_F;

		// get track data
		fwlite::Handle< vector<CTPPSLocalTrackLite> > hTracks;
		hTracks.getByLabel(ev, "ctppsLocalTrackLiteProducer");
		for (const auto &tr : *hTracks)
		{
			CTPPSDetId rpId(tr.getRPId());
			unsigned int rpDecId = rpId.arm()*100 + rpId.station()*10 + rpId.rp();

			CTPPSLocalTrackLite *dest = NULL;

			if (rpDecId == 23)
				dest = &tr_L_2_F;
			if (rpDecId == 3)
				dest = &tr_L_1_F;
			if (rpDecId == 103)
				dest = &tr_R_1_F;
			if (rpDecId == 123)
				dest = &tr_R_2_F;

			if (dest == NULL)
				continue;

			*dest = CTPPSLocalTrackLite(tr.getRPId(),
					tr.getX() + cfg.alignment_corrections_x[rpDecId], tr.getXUnc(),
					tr.getY(), tr.getYUnc()
				);
		}

		bool tr_L_2_F_valid = (tr_L_2_F.getRPId() != 0);
		bool tr_L_1_F_valid = (tr_L_1_F.getRPId() != 0);
		bool tr_R_1_F_valid = (tr_R_1_F.getRPId() != 0);
		bool tr_R_2_F_valid = (tr_R_2_F.getRPId() != 0);

		// process track data
		if (tr_L_2_F_valid)
			h2_y_vs_x_L_2_F_no_sel->Fill(tr_L_2_F.getX(), tr_L_2_F.getY());
		if (tr_L_1_F_valid)
			h2_y_vs_x_L_1_F_no_sel->Fill(tr_L_1_F.getX(), tr_L_1_F.getY());
		if (tr_R_1_F_valid)
			h2_y_vs_x_R_1_F_no_sel->Fill(tr_R_1_F.getX(), tr_R_1_F.getY());
		if (tr_R_2_F_valid)
			h2_y_vs_x_R_2_F_no_sel->Fill(tr_R_2_F.getX(), tr_R_2_F.getY());

		if (tr_L_1_F_valid && tr_L_2_F_valid)
		{
			h2_x_L_2_F_vs_x_L_1_F_before->Fill(tr_L_1_F.getX(), tr_L_2_F.getX());
			h2_y_L_2_F_vs_y_L_1_F_before->Fill(tr_L_1_F.getY(), tr_L_2_F.getY());

			double cq1 = tr_L_2_F.getX() + cfg.cut1_a * tr_L_1_F.getX() + cfg.cut1_c;
			h_q_cut1_before->Fill(cq1);
			bool cut1_val = (fabs(cq1) < cfg.n_si * cfg.cut1_si);

			double cq3 = tr_L_2_F.getY() + cfg.cut3_a * tr_L_1_F.getY() + cfg.cut3_c;
			h_q_cut3_before->Fill(cq3);
			bool cut3_val = (fabs(cq3) < cfg.n_si * cfg.cut3_si);

			bool cuts_passed = true;
			if (cfg.cut1_apply)
				cuts_passed &= cut1_val;
			if (cfg.cut3_apply)
				cuts_passed &= cut3_val;

			if (cuts_passed)
			{
				tr_sel_count++;

				h2_x_L_2_F_vs_x_L_1_F_after->Fill(tr_L_1_F.getX(), tr_L_2_F.getX());
				h2_y_L_2_F_vs_y_L_1_F_after->Fill(tr_L_1_F.getY(), tr_L_2_F.getY());

				p_x_L_2_F_vs_x_L_1_F_after->Fill(tr_L_1_F.getX(), tr_L_2_F.getX());
				p_y_L_2_F_vs_y_L_1_F_after->Fill(tr_L_1_F.getY(), tr_L_2_F.getY());

				h_q_cut1_after->Fill(cq1);
				h_q_cut3_after->Fill(cq3);

				int idx = g_y_vs_x_L_1_F_sel->GetN();
				g_y_vs_x_L_1_F_sel->SetPoint(idx, tr_L_1_F.getX(), tr_L_1_F.getY());
				g_y_vs_x_L_2_F_sel->SetPoint(idx, tr_L_2_F.getX(), tr_L_2_F.getY());

				h2_y_vs_x_L_1_F_sel->Fill(tr_L_1_F.getX(), tr_L_1_F.getY());
				h2_y_vs_x_L_2_F_sel->Fill(tr_L_2_F.getX(), tr_L_2_F.getY());

				p_y_vs_x_L_1_F_sel.Fill(tr_L_1_F.getX(), tr_L_1_F.getY());
				p_y_vs_x_L_2_F_sel.Fill(tr_L_2_F.getX(), tr_L_2_F.getY());
			}
		}

		if (tr_R_1_F_valid && tr_R_2_F_valid)
		{
			h2_x_R_2_F_vs_x_R_1_F_before->Fill(tr_R_1_F.getX(), tr_R_2_F.getX());
			h2_y_R_2_F_vs_y_R_1_F_before->Fill(tr_R_1_F.getY(), tr_R_2_F.getY());

			double cq2 = tr_R_2_F.getX() + cfg.cut2_a * tr_R_1_F.getX() + cfg.cut2_c;
			h_q_cut2_before->Fill(cq2);
			bool cut2_val = (fabs(cq2) < cfg.n_si * cfg.cut2_si);

			double cq4 = tr_R_2_F.getY() + cfg.cut4_a * tr_R_1_F.getY() + cfg.cut4_c;
			h_q_cut4_before->Fill(cq4);
			bool cut4_val = (fabs(cq4) < cfg.n_si * cfg.cut4_si);

			bool cuts_passed = true;
			if (cfg.cut2_apply)
				cuts_passed &= cut2_val;
			if (cfg.cut4_apply)
				cuts_passed &= cut4_val;

			if (cuts_passed)
			{
				tr_sel_count++;

				h2_x_R_2_F_vs_x_R_1_F_after->Fill(tr_R_1_F.getX(), tr_R_2_F.getX());
				h2_y_R_2_F_vs_y_R_1_F_after->Fill(tr_R_1_F.getY(), tr_R_2_F.getY());

				p_x_R_2_F_vs_x_R_1_F_after->Fill(tr_R_1_F.getX(), tr_R_2_F.getX());
				p_y_R_2_F_vs_y_R_1_F_after->Fill(tr_R_1_F.getY(), tr_R_2_F.getY());

				h_q_cut2_after->Fill(cq2);
				h_q_cut4_after->Fill(cq4);

				int idx = g_y_vs_x_R_1_F_sel->GetN();
				g_y_vs_x_R_1_F_sel->SetPoint(idx, tr_R_1_F.getX(), tr_R_1_F.getY());
				g_y_vs_x_R_2_F_sel->SetPoint(idx, tr_R_2_F.getX(), tr_R_2_F.getY());

				h2_y_vs_x_R_1_F_sel->Fill(tr_R_1_F.getX(), tr_R_1_F.getY());
				h2_y_vs_x_R_2_F_sel->Fill(tr_R_2_F.getX(), tr_R_2_F.getY());

				p_y_vs_x_R_1_F_sel.Fill(tr_R_1_F.getX(), tr_R_1_F.getY());
				p_y_vs_x_R_2_F_sel.Fill(tr_R_2_F.getX(), tr_R_2_F.getY());
			}
		}
	}

	printf("* events processed: %lu\n", ev_count);
	printf("* tracks selected (both arms): %lu\n", tr_sel_count);

	// save histograms
	gDirectory = f_out;

	// make fits
	TF1 *ff_pol1 = new TF1("ff_pol1", "[0] + [1]*x");

	double fx_min, fx_max;

	ff_pol1->FixParameter(1, 1.);

	fx_min = (cfg.aligned) ? 3. : 7.;
	fx_max = (cfg.aligned) ? 7.5 : 14.;
	p_x_L_2_F_vs_x_L_1_F_after->Fit(ff_pol1, "Q", "", fx_min, fx_max);
	printf("\tcut1_a = %+.3f; cut1_c = %+.3f; cut1_si = 0.20;\n", -ff_pol1->GetParameter(1), -ff_pol1->GetParameter(0));

	fx_min = (cfg.aligned) ? 2. : 7.;
	fx_max = (cfg.aligned) ? 6. : 16.;
	p_x_R_2_F_vs_x_R_1_F_after->Fit(ff_pol1, "Q", "", fx_min, fx_max);
	printf("\tcut2_a = %+.3f; cut2_c = %+.3f; cut2_si = 0.20;\n", -ff_pol1->GetParameter(1), -ff_pol1->GetParameter(0));

	fx_min = (cfg.aligned) ? -2.5 : -6.5;
	fx_max = (cfg.aligned) ? -2.5 : +6.5;

	p_y_L_2_F_vs_y_L_1_F_after->Fit(ff_pol1, "Q", "", fx_min, fx_max);
	printf("\tcut3_a = %+.3f; cut3_c = %+.3f; cut3_si = 0.15;\n", -ff_pol1->GetParameter(1), -ff_pol1->GetParameter(0));

	p_y_R_2_F_vs_y_R_1_F_after->Fit(ff_pol1, "Q", "", fx_min, fx_max);
	printf("\tcut4_a = %+.3f; cut4_c = %+.3f; cut4_si = 0.15;\n", -ff_pol1->GetParameter(1), -ff_pol1->GetParameter(0));

	// save histograms
	gDirectory = f_out->mkdir("before selection");
	h2_y_vs_x_L_2_F_no_sel->Write();
	h2_y_vs_x_L_1_F_no_sel->Write();
	h2_y_vs_x_R_1_F_no_sel->Write();
	h2_y_vs_x_R_2_F_no_sel->Write();

	TDirectory *d_cuts = f_out->mkdir("cuts");

	gDirectory = d_cuts->mkdir("cut 1");
	WriteCutPlot(h2_x_L_2_F_vs_x_L_1_F_before, cfg.cut1_a, cfg.cut1_c, cfg.cut1_si, "canvas_before");
	WriteCutPlot(h2_x_L_2_F_vs_x_L_1_F_after, cfg.cut1_a, cfg.cut1_c, cfg.cut1_si, "canvas_after");
	p_x_L_2_F_vs_x_L_1_F_after->Write();
	h_q_cut1_before->Write();
	h_q_cut1_after->Write();

	gDirectory = d_cuts->mkdir("cut 2");
	WriteCutPlot(h2_x_R_2_F_vs_x_R_1_F_before, cfg.cut2_a, cfg.cut2_c, cfg.cut2_si, "canvas_before");
	WriteCutPlot(h2_x_R_2_F_vs_x_R_1_F_after, cfg.cut2_a, cfg.cut2_c, cfg.cut2_si, "canvas_after");
	p_x_R_2_F_vs_x_R_1_F_after->Write();
	h_q_cut2_before->Write();
	h_q_cut2_after->Write();

	gDirectory = d_cuts->mkdir("cut 3");
	WriteCutPlot(h2_y_L_2_F_vs_y_L_1_F_before, cfg.cut3_a, cfg.cut3_c, cfg.cut3_si, "canvas_before");
	WriteCutPlot(h2_y_L_2_F_vs_y_L_1_F_after, cfg.cut3_a, cfg.cut3_c, cfg.cut3_si, "canvas_after");
	p_y_L_2_F_vs_y_L_1_F_after->Write();
	h_q_cut3_before->Write();
	h_q_cut3_after->Write();

	gDirectory = d_cuts->mkdir("cut 4");
	WriteCutPlot(h2_y_R_2_F_vs_y_R_1_F_before, cfg.cut4_a, cfg.cut4_c, cfg.cut4_si, "canvas_before");
	WriteCutPlot(h2_y_R_2_F_vs_y_R_1_F_after, cfg.cut4_a, cfg.cut4_c, cfg.cut4_si, "canvas_after");
	p_y_R_2_F_vs_y_R_1_F_after->Write();
	h_q_cut4_before->Write();
	h_q_cut4_after->Write();

	gDirectory = f_out->mkdir("after selection");
	g_y_vs_x_L_2_F_sel->Write();
	g_y_vs_x_L_1_F_sel->Write();
	g_y_vs_x_R_1_F_sel->Write();
	g_y_vs_x_R_2_F_sel->Write();

	h2_y_vs_x_L_2_F_sel->Write();
	h2_y_vs_x_L_1_F_sel->Write();
	h2_y_vs_x_R_1_F_sel->Write();
	h2_y_vs_x_R_2_F_sel->Write();

	gDirectory = f_out->mkdir("profiles");
	p_y_vs_x_L_2_F_sel.Write();
	p_y_vs_x_L_1_F_sel.Write();
	p_y_vs_x_R_1_F_sel.Write();
	p_y_vs_x_R_2_F_sel.Write();

	// clean up
	delete f_out;
	return 0;
}
