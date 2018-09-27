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
#include "DataFormats/Common/interface/DetSetVector.h"
#include "DataFormats/CTPPSReco/interface/TotemRPLocalTrack.h"

#include <vector>
#include <string>

using namespace std;
using namespace edm;

//----------------------------------------------------------------------------------------------------

struct Profile
{
	TH2D *h;

	vector<Stat> st;

	Profile()
	{
	}

	Profile(TH2D *_h) : h(_h), st(h->GetNbinsX(), Stat(1))
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

	void Write() const
	{
		const int bins = h->GetXaxis()->GetNbins();
		const double x_min = h->GetXaxis()->GetXmin();
		const double x_max = h->GetXaxis()->GetXmax();

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

struct SectorData
{
	string name;

	unsigned int rpIdUp, rpIdDw;

	SectorConfig scfg;

	// hit distributions
	map<unsigned int, TH1D*> m_h1_x_bef_sel;

	map<unsigned int, TH2D*> m_h2_y_vs_x_bef_sel;

	map<unsigned int, TH2D*> m_h2_y_vs_x_aft_sel;
	map<unsigned int, TGraph*> m_g_y_vs_x_aft_sel;

	// cut plots
	TH1D *h_q_cut_h_bef, *h_q_cut_h_aft;
	TH2D *h2_cut_h_bef, *h2_cut_h_aft;
	TProfile *p_cut_h_aft;

	TH1D *h_q_cut_v_bef, *h_q_cut_v_aft;
	TH2D *h2_cut_v_bef, *h2_cut_v_aft;
	TProfile *p_cut_v_aft;

	// profiles
	map<unsigned int, Profile> m_p_y_vs_x_aft_sel;

	// near-far plots
	TProfile *p_x_diffFN_vs_x_N;
	TProfile *p_y_diffFN_vs_y_N;
	TProfile *p_y_diffFN_vs_y_F;

	map<unsigned int, TProfile *> x_slice_p_y_diffFN_vs_y_F, x_slice_p_y_diffFN_vs_y_N;

	SectorData(const string _name, unsigned int _rpIdUp, unsigned int _rpIdDw, const SectorConfig &_scfg);

	unsigned int Process(const vector<CTPPSLocalTrackLite> &tracks);

	void MakeFits();

	void Write() const;
};

//----------------------------------------------------------------------------------------------------

SectorData::SectorData(const string _name, unsigned int _rpIdUp, unsigned int _rpIdDw, const SectorConfig &_scfg) :
	name(_name), rpIdUp(_rpIdUp), rpIdDw(_rpIdDw), scfg(_scfg)
{
	// binning
	const double bin_size_x = 142.3314E-3; // mm
	const unsigned int n_bins_x = 210;

	const double pixel_x_offset = (cfg.aligned) ? 0. : 40.;

	const double x_min_pix = pixel_x_offset, x_max_pix = pixel_x_offset + n_bins_x * bin_size_x;
	const double x_min_str = 0., x_max_str = n_bins_x * bin_size_x;

	const unsigned int n_bins_y = 200;
	const double y_min = -20., y_max = +20.;

	// hit distributions
	m_h1_x_bef_sel[rpIdUp] = new TH1D("", ";x", 10*n_bins_x, x_min_str, x_max_str);
	m_h1_x_bef_sel[rpIdDw] = new TH1D("", ";x", 10*n_bins_x, x_min_pix, x_max_pix);

	m_h2_y_vs_x_bef_sel[rpIdUp] = new TH2D("", ";x;y", n_bins_x, x_min_str, x_max_str, n_bins_y, y_min, y_max);
	m_h2_y_vs_x_bef_sel[rpIdDw] = new TH2D("", ";x;y", n_bins_x, x_min_pix, x_max_pix, n_bins_y, y_min, y_max);

	m_h2_y_vs_x_aft_sel[rpIdUp] = new TH2D("", ";x;y", n_bins_x, x_min_str, x_max_str, n_bins_y, y_min, y_max);
	m_h2_y_vs_x_aft_sel[rpIdDw] = new TH2D("", ";x;y", n_bins_x, x_min_pix, x_max_pix, n_bins_y, y_min, y_max);

	m_g_y_vs_x_aft_sel[rpIdUp] = new TGraph();
	m_g_y_vs_x_aft_sel[rpIdDw] = new TGraph();

	// cut plots
	h_q_cut_h_bef = new TH1D("", ";cq_h", 400, -2., 2.);
	h_q_cut_h_aft = new TH1D("", ";cq_h", 400, -2., 2.);
	h2_cut_h_bef = new TH2D("", ";x_up;x_dw", n_bins_x, x_min_str, x_max_str, n_bins_x, x_min_pix, x_max_pix);
	h2_cut_h_aft = new TH2D("", ";x_up;x_dw", n_bins_x, x_min_str, x_max_str, n_bins_x, x_min_pix, x_max_pix);
	p_cut_h_aft = new TProfile("", ";x_up;mean of x_dw", n_bins_x, x_min_str, x_max_str);

	h_q_cut_v_bef = new TH1D("", ";cq_v", 400, -2., 2.);
	h_q_cut_v_aft = new TH1D("", ";cq_v", 400, -2., 2.);
	h2_cut_v_bef = new TH2D("", ";y_up;y_dw", n_bins_y, y_min, y_max, n_bins_y, y_min, y_max);
	h2_cut_v_aft = new TH2D("", ";y_up;y_dw", n_bins_y, y_min, y_max, n_bins_y, y_min, y_max);
	p_cut_v_aft = new TProfile("", ";y_up;mean of y_dw", n_bins_y, y_min, y_max);

	// profiles
	m_p_y_vs_x_aft_sel[rpIdUp] = Profile(m_h2_y_vs_x_aft_sel[rpIdUp]);
	m_p_y_vs_x_aft_sel[rpIdDw] = Profile(m_h2_y_vs_x_aft_sel[rpIdDw]);

	// near-far plots
	p_x_diffFN_vs_x_N = new TProfile("", ";x_{N};x_{F} - x_{N}", 100, 0., 20.);
	p_y_diffFN_vs_y_N = new TProfile("", ";y_{N};y_{F} - y_{N}", 200, -10., 10.);
	p_y_diffFN_vs_y_F = new TProfile("", ";y_{F};y_{F} - y_{N}", 200, -10., 10.);

	for (int i = 0; i < scfg.nr_x_slice_n; ++i)
		x_slice_p_y_diffFN_vs_y_N[i] = new TProfile("", ";y_{N};x_{F} - y_{N}", 100, -10., +10.);

	for (int i = 0; i < scfg.fr_x_slice_n; ++i)
		x_slice_p_y_diffFN_vs_y_F[i] = new TProfile("", ";y_{F};x_{F} - y_{N}", 100, -10., +10.);
}

//----------------------------------------------------------------------------------------------------

unsigned int SectorData::Process(const vector<CTPPSLocalTrackLite> &tracks)
{
	// build a collection of upstream and downstream (correcte) tracks
	vector<CTPPSLocalTrackLite> tracksUp, tracksDw;

	for (const auto &tr : tracks)
	{
		CTPPSDetId rpId(tr.getRPId());
		unsigned int rpDecId = rpId.arm()*100 + rpId.station()*10 + rpId.rp();

		if (rpDecId != rpIdUp && rpDecId != rpIdDw)
			continue;

		double x = tr.getX();
		double y = tr.getY();

		// apply alignment corrections
		x += cfg.alignment_corrections_x[rpDecId];

		// re-build track object
		CTPPSLocalTrackLite tr_corr(tr.getRPId(), x, 0., y, 0.);

		// store corrected track into the right collection
		if (rpDecId == rpIdUp)
			tracksUp.push_back(std::move(tr_corr));
		if (rpDecId == rpIdDw)
			tracksDw.push_back(std::move(tr_corr));
	}

	// update plots before selection
	for (const auto &tr : tracksUp)
	{
		m_h1_x_bef_sel[rpIdUp]->Fill(tr.getX());
		m_h2_y_vs_x_bef_sel[rpIdUp]->Fill(tr.getX(), tr.getY());
	}

	for (const auto &tr : tracksDw)
	{
		m_h1_x_bef_sel[rpIdDw]->Fill(tr.getX());
		m_h2_y_vs_x_bef_sel[rpIdDw]->Fill(tr.getX(), tr.getY());
	}

	// skip crowded events
	if (tracksUp.size() > 1)
		return 0;

	if (tracksDw.size() > 1)
		return 0;

	// do the selection
	unsigned int pairs_selected = 0;

	for (const auto &trUp : tracksUp)
	{
		for (const auto &trDw : tracksDw)
		{
			h2_cut_h_bef->Fill(trUp.getX(), trDw.getX());
			h2_cut_v_bef->Fill(trUp.getY(), trDw.getY());

			const double cq_h = trDw.getX() + scfg.cut_h_a * trUp.getX() + scfg.cut_h_c;
			h_q_cut_h_bef->Fill(cq_h);
			const bool cv_h = (fabs(cq_h) < cfg.n_si * scfg.cut_h_si);

			const double cq_v = trDw.getY() + scfg.cut_v_a * trUp.getY() + scfg.cut_v_c;
			h_q_cut_v_bef->Fill(cq_v);
			const bool cv_v = (fabs(cq_v) < cfg.n_si * scfg.cut_v_si);

			bool cuts_passed = true;
			if (scfg.cut_h_apply)
				cuts_passed &= cv_h;
			if (scfg.cut_v_apply)
				cuts_passed &= cv_v;

			if (cuts_passed)
			{
				pairs_selected++;

				h_q_cut_h_aft->Fill(cq_h);
				h_q_cut_v_aft->Fill(cq_v);

				h2_cut_h_aft->Fill(trUp.getX(), trDw.getX());
				h2_cut_v_aft->Fill(trUp.getY(), trDw.getY());

				p_cut_h_aft->Fill(trUp.getX(), trDw.getX());
				p_cut_v_aft->Fill(trUp.getY(), trDw.getY());

				m_h2_y_vs_x_aft_sel[rpIdUp]->Fill(trUp.getX(), trUp.getY());
				m_h2_y_vs_x_aft_sel[rpIdDw]->Fill(trDw.getX(), trDw.getY());

				int idx = m_g_y_vs_x_aft_sel[rpIdUp]->GetN();
				m_g_y_vs_x_aft_sel[rpIdUp]->SetPoint(idx, trUp.getX(), trUp.getY());
				m_g_y_vs_x_aft_sel[rpIdDw]->SetPoint(idx, trDw.getX(), trDw.getY());

				m_p_y_vs_x_aft_sel[rpIdUp].Fill(trUp.getX(), trUp.getY());
				m_p_y_vs_x_aft_sel[rpIdDw].Fill(trDw.getX(), trDw.getY());

				p_x_diffFN_vs_x_N->Fill(trUp.getX(), trDw.getX() - trUp.getX());

				const auto &range = cfg.alignment_y_alt_ranges[rpIdUp];
				if (trUp.getX() > range.x_min && trUp.getX() < range.x_max)
				{
					p_y_diffFN_vs_y_N->Fill(trUp.getY(), trDw.getY() - trUp.getY());
					p_y_diffFN_vs_y_F->Fill(trDw.getY(), trDw.getY() - trUp.getY());
				}

				idx = (trUp.getX() - scfg.nr_x_slice_min) / scfg.nr_x_slice_w;
				if (idx >= 0 && idx < scfg.nr_x_slice_n)
					x_slice_p_y_diffFN_vs_y_N[idx]->Fill(trUp.getY(), trDw.getY() - trUp.getY());

				idx = (trDw.getX() - scfg.fr_x_slice_min) / scfg.fr_x_slice_w;
				if (idx >= 0 && idx < scfg.fr_x_slice_n)
					x_slice_p_y_diffFN_vs_y_F[idx]->Fill(trDw.getY(), trDw.getY() - trUp.getY());
			}
		}
	}

	return pairs_selected;
}

//----------------------------------------------------------------------------------------------------

void SectorData::MakeFits()
{
}

//----------------------------------------------------------------------------------------------------

void SectorData::Write() const
{
	TDirectory *d_top = gDirectory;

	TDirectory *d_sector = d_top->mkdir(name.c_str());

	// before selection
	TDirectory *d_bef_sel = d_sector->mkdir("before selection");
	for (const auto &p : m_h2_y_vs_x_bef_sel)
	{
		gDirectory = d_bef_sel->mkdir(cfg.rp_tags[p.first].c_str());

		const auto it = m_h1_x_bef_sel.find(p.first);
		it->second->Write("h_x");

		p.second->Write("h2_y_vs_x");
	}

	// cut plots
	TDirectory *d_cuts = d_sector->mkdir("cuts");

	gDirectory = d_cuts->mkdir("cut_h");
	h_q_cut_h_bef->Write("h_q_cut_h_bef");
	h_q_cut_h_aft->Write("h_q_cut_h_aft");
	WriteCutPlot(h2_cut_h_bef, scfg.cut_h_a, scfg.cut_h_c, scfg.cut_h_si, "canvas_before");
	WriteCutPlot(h2_cut_h_aft, scfg.cut_h_a, scfg.cut_h_c, scfg.cut_h_si, "canvas_after");
	p_cut_h_aft->Write("p_cut_h_aft");

	gDirectory = d_cuts->mkdir("cut_v");
	h_q_cut_v_bef->Write("h_q_cut_v_bef");
	h_q_cut_v_aft->Write("h_q_cut_v_aft");
	WriteCutPlot(h2_cut_v_bef, scfg.cut_v_a, scfg.cut_v_c, scfg.cut_v_si, "canvas_before");
	WriteCutPlot(h2_cut_v_aft, scfg.cut_v_a, scfg.cut_v_c, scfg.cut_v_si, "canvas_after");
	p_cut_v_aft->Write("p_cut_v_aft");

	// after selection
	TDirectory *d_aft_sel = d_sector->mkdir("after selection");
	for (const auto &p : m_h2_y_vs_x_aft_sel)
	{
		gDirectory = d_aft_sel->mkdir(cfg.rp_tags[p.first].c_str());
		p.second->Write("h2_y_vs_x");

		const auto git = m_g_y_vs_x_aft_sel.find(p.first);
		git->second->Write("g_y_vs_x");
	}

	// profiles
	TDirectory *d_profiles = d_sector->mkdir("profiles");
	for (const auto &p : m_p_y_vs_x_aft_sel)
	{
		gDirectory = d_profiles->mkdir(cfg.rp_tags[p.first].c_str());
		p.second.Write();
	}

	// near-far plots
	TDirectory *d_near_far = d_sector->mkdir("near_far");
	gDirectory = d_near_far;

	p_x_diffFN_vs_x_N->Write("p_x_diffFN_vs_x_N");
	p_y_diffFN_vs_y_N->Write("p_y_diffFN_vs_y_N");
	p_y_diffFN_vs_y_F->Write("p_y_diffFN_vs_y_F");

	gDirectory = d_near_far->mkdir("p_y_diffFN_vs_y_N, x slices");
	for (const auto &p : x_slice_p_y_diffFN_vs_y_N)
	{
		const double x_min = scfg.nr_x_slice_min + p.first * scfg.nr_x_slice_w;
		const double x_max = scfg.nr_x_slice_min + (p.first+1) * scfg.nr_x_slice_w;

		char buf[100];
		sprintf(buf, "%.1f-%.1f", x_min, x_max);
		p.second->Write(buf);
	}

	gDirectory = d_near_far->mkdir("p_y_diffFN_vs_y_F, x slices");
	for (const auto &p : x_slice_p_y_diffFN_vs_y_F)
	{
		const double x_min = scfg.fr_x_slice_min + p.first * scfg.fr_x_slice_w;
		const double x_max = scfg.fr_x_slice_min + (p.first+1) * scfg.fr_x_slice_w;

		char buf[100];
		sprintf(buf, "%.1f-%.1f", x_min, x_max);
		p.second->Write(buf);
	}

	// clean up
	gDirectory = d_top;
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

	// TODO
	//if (cfg.input_files.size() > 15)
	//	cfg.input_files.resize(15);

	printf("-------------------- config ----------------------\n");
	cfg.Print(true);
	printf("--------------------------------------------------\n");

	// setup input
	fwlite::ChainEvent ev(cfg.input_files);

	printf("* events in input chain: %llu\n", ev.size());

	// ouput file
	TFile *f_out = new TFile("distributions.root", "recreate");

	// book data structures
	SectorData sectorData45("sector 45", 3, 23, cfg.sectorConfig45);
	SectorData sectorData56("sector 56", 103, 123, cfg.sectorConfig56);

	// loop over the chain entries
	unsigned long int ev_count = 0;
	unsigned long int ev_sel_count_45 = 0;
	unsigned long int ev_sel_count_56 = 0;
	for (ev.toBegin(); ! ev.atEnd(); ++ev)
	{
		ev_count++;

		// TODO: comment out
		//if (ev_sel_count_45 + ev_sel_count_56 > 10000)
		//	break;

		// get track data
		fwlite::Handle< vector<CTPPSLocalTrackLite> > hTracks;
		hTracks.getByLabel(ev, "ctppsLocalTrackLiteProducer");

		// process tracks
		if (sectorData45.Process(*hTracks))
			ev_sel_count_45++;

		if (sectorData56.Process(*hTracks))
			ev_sel_count_56++;
	}

	printf("* events processed: %lu\n", ev_count);
	printf("* events selected in 45: %lu\n", ev_sel_count_45);
	printf("* events selected in 56: %lu\n", ev_sel_count_56);

	// save histograms
	gDirectory = f_out;

	// make fits
	sectorData45.MakeFits();
	sectorData56.MakeFits();

	// save histograms
	sectorData45.Write();
	sectorData56.Write();

	// clean up
	delete f_out;
	return 0;
}
