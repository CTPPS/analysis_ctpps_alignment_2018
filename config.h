#ifndef _config_h_
#define _config_h_

#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "FWCore/PythonParameterSet/interface/MakeParameterSets.h"

#include <vector>
#include <string>
#include <cmath>

using namespace std;

//----------------------------------------------------------------------------------------------------

struct SelectionRange
{
	double x_min;
	double x_max;

	SelectionRange(double _xmi=0., double _xma=0.) : x_min(_xmi), x_max(_xma)
	{
	}
};

//----------------------------------------------------------------------------------------------------

struct SectorConfig
{
	bool cut_h_apply;
	double cut_h_a, cut_h_c, cut_h_si;

	bool cut_v_apply;
	double cut_v_a, cut_v_c, cut_v_si;

	signed int nr_x_slice_n;
	double nr_x_slice_min, nr_x_slice_w;
	signed int fr_x_slice_n;
	double fr_x_slice_min, fr_x_slice_w;
};

//----------------------------------------------------------------------------------------------------

struct Config
{
	unsigned int fill;
	unsigned int xangle;
	double beta;
	string dataset;

	map<unsigned int, string> rp_tags;

	vector<string> input_files;

	map<unsigned int, double> alignment_corrections_x;

	bool aligned;

	double n_si;

	SectorConfig sectorConfig45, sectorConfig56;

	vector<string> matching_reference_datasets;
	map<unsigned int, SelectionRange> matching_shift_ranges;

	map<unsigned int, SelectionRange> alignment_x_meth_x_ranges;
	map<unsigned int, SelectionRange> alignment_x_meth_y_ranges;
	map<unsigned int, SelectionRange> alignment_x_meth_o_ranges;
	map<unsigned int, SelectionRange> alignment_x_relative_ranges;

	map<unsigned int, SelectionRange> alignment_y_ranges;
	map<unsigned int, SelectionRange> alignment_y_alt_ranges;

	int LoadFrom(const string &f);

	void Print(bool print_input_files=false) const;
};

//----------------------------------------------------------------------------------------------------

int Config::LoadFrom(const string &f_in)
{
	rp_tags = {
		{ 23, "L_2_F" },
		{ 3, "L_1_F" },
		{ 103, "R_1_F" },
		{ 123, "R_2_F" }
	};

	const edm::ParameterSet& config = edm::readPSetsFrom(f_in)->getParameter<edm::ParameterSet>("config");

	fill = config.getParameter<unsigned int>("fill");
	xangle = config.getParameter<unsigned int>("xangle");
	beta = config.getParameter<double>("beta");
	dataset = config.getParameter<string>("dataset");

	input_files = config.getParameter<vector<string>>("input_files");

	const auto &acc = config.getParameter<edm::ParameterSet>("alignment_corrections");
	for (const auto &p : rp_tags)
	{
		const auto &ps = acc.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_corrections_x[p.first] = ps.getParameter<double>("de_x");
	}

	aligned = config.getParameter<bool>("aligned");

	n_si = config.getParameter<double>("n_si");

	{
		const auto &sps = config.getParameter<edm::ParameterSet>("sector_45");

		sectorConfig45.cut_h_apply = sps.getParameter<bool>("cut_h_apply");
		sectorConfig45.cut_h_a = sps.getParameter<double>("cut_h_a");
		sectorConfig45.cut_h_c = sps.getParameter<double>("cut_h_c");
		sectorConfig45.cut_h_si = sps.getParameter<double>("cut_h_si");

		sectorConfig45.cut_v_apply = sps.getParameter<bool>("cut_v_apply");
		sectorConfig45.cut_v_a = sps.getParameter<double>("cut_v_a");
		sectorConfig45.cut_v_c = sps.getParameter<double>("cut_v_c");
		sectorConfig45.cut_v_si = sps.getParameter<double>("cut_v_si");

		sectorConfig45.nr_x_slice_min = sps.getParameter<double>("nr_x_slice_min");
		sectorConfig45.nr_x_slice_w = sps.getParameter<double>("nr_x_slice_w");
		sectorConfig45.nr_x_slice_n = ceil((sps.getParameter<double>("nr_x_slice_max") - sectorConfig45.nr_x_slice_min) / sectorConfig45.nr_x_slice_w);

		sectorConfig45.fr_x_slice_min = sps.getParameter<double>("fr_x_slice_min");
		sectorConfig45.fr_x_slice_w = sps.getParameter<double>("fr_x_slice_w");
		sectorConfig45.fr_x_slice_n = ceil((sps.getParameter<double>("fr_x_slice_max") - sectorConfig45.fr_x_slice_min) / sectorConfig45.fr_x_slice_w);
	}

	{
		const auto &sps = config.getParameter<edm::ParameterSet>("sector_56");

		sectorConfig56.cut_h_apply = sps.getParameter<bool>("cut_h_apply");
		sectorConfig56.cut_h_a = sps.getParameter<double>("cut_h_a");
		sectorConfig56.cut_h_c = sps.getParameter<double>("cut_h_c");
		sectorConfig56.cut_h_si = sps.getParameter<double>("cut_h_si");

		sectorConfig56.cut_v_apply = sps.getParameter<bool>("cut_v_apply");
		sectorConfig56.cut_v_a = sps.getParameter<double>("cut_v_a");
		sectorConfig56.cut_v_c = sps.getParameter<double>("cut_v_c");
		sectorConfig56.cut_v_si = sps.getParameter<double>("cut_v_si");

		sectorConfig56.nr_x_slice_min = sps.getParameter<double>("nr_x_slice_min");
		sectorConfig56.nr_x_slice_w = sps.getParameter<double>("nr_x_slice_w");
		sectorConfig56.nr_x_slice_n = ceil((sps.getParameter<double>("nr_x_slice_max") - sectorConfig56.nr_x_slice_min) / sectorConfig56.nr_x_slice_w);

		sectorConfig56.fr_x_slice_min = sps.getParameter<double>("fr_x_slice_min");
		sectorConfig56.fr_x_slice_w = sps.getParameter<double>("fr_x_slice_w");
		sectorConfig56.fr_x_slice_n = ceil((sps.getParameter<double>("fr_x_slice_max") - sectorConfig56.fr_x_slice_min) / sectorConfig56.fr_x_slice_w);
	}

	const auto &c_m = config.getParameter<edm::ParameterSet>("matching");
	matching_reference_datasets = c_m.getParameter<vector<string>>("reference_datasets");

	for (const auto &p : rp_tags)
	{
		const auto &ps = c_m.getParameter<edm::ParameterSet>("rp_" + p.second);
		matching_shift_ranges[p.first] = SelectionRange(ps.getParameter<double>("sh_min"), ps.getParameter<double>("sh_max"));
	}

	const auto &c_axx = config.getParameter<edm::ParameterSet>("x_alignment_meth_x");
	for (const auto &p : rp_tags)
	{
		const auto &ps = c_axx.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_x_meth_x_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
	}

	const auto &c_axy = config.getParameter<edm::ParameterSet>("x_alignment_meth_y");
	for (const auto &p : rp_tags)
	{
		const auto &ps = c_axy.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_x_meth_y_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
	}

	const auto &c_axo = config.getParameter<edm::ParameterSet>("x_alignment_meth_o");
	for (const auto &p : rp_tags)
	{
		const auto &ps = c_axo.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_x_meth_o_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
	}

	const auto &c_axr = config.getParameter<edm::ParameterSet>("x_alignment_relative");
	for (const auto &p : rp_tags)
	{
		const auto &ps = c_axr.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_x_relative_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
	}

	const auto &c_ay = config.getParameter<edm::ParameterSet>("y_alignment");
	for (const auto &p : rp_tags)
	{
		const auto &ps = c_ay.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_y_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
	}

	const auto &c_aya = config.getParameter<edm::ParameterSet>("y_alignment_alt");
	for (const auto &p : rp_tags)
	{
		const auto &ps = c_aya.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_y_alt_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
	}

	return 0;
}

//----------------------------------------------------------------------------------------------------

void Config::Print(bool print_input_files) const
{
	if (print_input_files)
	{
		printf("* input files\n");
		for (const auto &f : input_files)
			printf("    %s\n", f.c_str());
		printf("\n");
	}

	printf("* general info\n");
	printf("    fill = %u\n", fill);
	printf("    xangle = %u\n", xangle);
	printf("    beta = %.2f\n", beta);
	printf("    dataset = %s\n", dataset.c_str());

	printf("\n");
	printf("* dataset already aligned\n");
	printf("    aligned = %u\n", aligned);

	printf("\n");
	printf("* alignment parameters\n");
	for (const auto &p : alignment_corrections_x)
		printf("    RP %u: de_x = %.3f mm\n", p.first, p.second);

	printf("\n");
	printf("* cuts\n");
	printf("    n_si = %.3f\n", n_si);

	printf("\n");
	printf("* sector 45\n");
	printf("    cut_h: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", sectorConfig45.cut_h_apply, sectorConfig45.cut_h_a, sectorConfig45.cut_h_c, sectorConfig45.cut_h_si);
	printf("    cut_v: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", sectorConfig45.cut_v_apply, sectorConfig45.cut_v_a, sectorConfig45.cut_v_c, sectorConfig45.cut_v_si);
	printf("    x slices, nr: min = %.2f, w = %.2f, n = %u\n", sectorConfig45.nr_x_slice_min, sectorConfig45.nr_x_slice_w, sectorConfig45.nr_x_slice_n);
	printf("    x slices, fr: min = %.2f, w = %.2f, n = %u\n", sectorConfig45.fr_x_slice_min, sectorConfig45.fr_x_slice_w, sectorConfig45.fr_x_slice_n);
	printf("* sector 56\n");
	printf("    cut_h: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", sectorConfig56.cut_h_apply, sectorConfig56.cut_h_a, sectorConfig56.cut_h_c, sectorConfig56.cut_h_si);
	printf("    cut_v: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", sectorConfig56.cut_v_apply, sectorConfig56.cut_v_a, sectorConfig56.cut_v_c, sectorConfig56.cut_v_si);
	printf("    x slices, nr: min = %.2f, w = %.2f, n = %u\n", sectorConfig56.nr_x_slice_min, sectorConfig56.nr_x_slice_w, sectorConfig56.nr_x_slice_n);
	printf("    x slices, fr: min = %.2f, w = %.2f, n = %u\n", sectorConfig56.fr_x_slice_min, sectorConfig56.fr_x_slice_w, sectorConfig56.fr_x_slice_n);

	printf("\n");
	printf("* matching\n");
	printf("    reference datasets (%lu):\n", matching_reference_datasets.size());
	for (const auto &ds : matching_reference_datasets)
		printf("        %s\n", ds.c_str());
	printf("    shift ranges:\n");
	for (const auto &p : matching_shift_ranges)
		printf("        RP %u: sh_min = %.3f, sh_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);

	printf("\n* alignment_x_meth_x\n");
	for (const auto &p : alignment_x_meth_x_ranges)
		printf("    RP %u: x_min = %.3f, x_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);

	printf("\n* alignment_x_meth_y\n");
	for (const auto &p : alignment_x_meth_y_ranges)
		printf("    RP %u: x_min = %.3f, x_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);

	printf("\n* alignment_x_meth_o\n");
	for (const auto &p : alignment_x_meth_o_ranges)
		printf("    RP %u: x_min = %.3f, x_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);

	printf("\n* alignment_x_relative\n");
	for (const auto &p : alignment_x_relative_ranges)
		printf("    RP %u: x_min = %.3f, x_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);

	printf("\n* alignment_y\n");
	for (const auto &p : alignment_y_ranges)
		printf("    RP %u: x_min = %.3f, x_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);

	printf("\n* alignment_y_alt\n");
	for (const auto &p : alignment_y_alt_ranges)
		printf("    RP %u: x_min = %.3f, x_max = %.3f\n", p.first, p.second.x_min, p.second.x_max);
}

//----------------------------------------------------------------------------------------------------

Config cfg;

#endif
