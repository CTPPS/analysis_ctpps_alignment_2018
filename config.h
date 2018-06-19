#ifndef _config_h_
#define _config_h_

#include "FWCore/ParameterSet/interface/ParameterSet.h"
#include "FWCore/PythonParameterSet/interface/MakeParameterSets.h"

#include <vector>
#include <string>

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

struct Config
{
	vector<string> input_files;

	map<unsigned int, double> alignment_corrections_x;

	bool aligned;

	double n_si;

	double cut1_a, cut1_c, cut1_si;
	double cut2_a, cut2_c, cut2_si;
	double cut3_a, cut3_c, cut3_si;
	double cut4_a, cut4_c, cut4_si;

	bool cut1_apply;
	bool cut2_apply;
	bool cut3_apply;
	bool cut4_apply;

	vector<string> matching_1d_reference_datasets;

	map<unsigned int, SelectionRange> matching_1d_ranges;
	map<unsigned int, SelectionRange> matching_1d_shift_ranges;

	int LoadFrom(const string &f);

	void Print(bool print_input_files=false) const;
};

//----------------------------------------------------------------------------------------------------

int Config::LoadFrom(const string &f_in)
{
	map<unsigned int, string> rp_tags = {
		{ 23, "L_2_F" },
		{ 3, "L_1_F" },
		{ 103, "R_1_F" },
		{ 123, "R_2_F" }
	};

	const edm::ParameterSet& config = edm::readPSetsFrom(f_in)->getParameter<edm::ParameterSet>("config");

	input_files = config.getParameter<vector<string>>("input_files");

	const auto &acc = config.getParameter<edm::ParameterSet>("alignment_corrections");
	for (const auto &p : rp_tags)
	{
		const auto &ps = acc.getParameter<edm::ParameterSet>("rp_" + p.second);
		alignment_corrections_x[p.first] = ps.getParameter<double>("de_x");
	}

	aligned = config.getParameter<bool>("aligned");

	n_si = config.getParameter<double>("n_si");

	cut1_apply = config.getParameter<bool>("cut1_apply");
	cut1_a = config.getParameter<double>("cut1_a");
	cut1_c = config.getParameter<double>("cut1_c");
	cut1_si = config.getParameter<double>("cut1_si");

	cut2_apply = config.getParameter<bool>("cut2_apply");
	cut2_a = config.getParameter<double>("cut2_a");
	cut2_c = config.getParameter<double>("cut2_c");
	cut2_si = config.getParameter<double>("cut2_si");

	cut3_apply = config.getParameter<bool>("cut3_apply");
	cut3_a = config.getParameter<double>("cut3_a");
	cut3_c = config.getParameter<double>("cut3_c");
	cut3_si = config.getParameter<double>("cut3_si");

	cut4_apply = config.getParameter<bool>("cut4_apply");
	cut4_a = config.getParameter<double>("cut4_a");
	cut4_c = config.getParameter<double>("cut4_c");
	cut4_si = config.getParameter<double>("cut4_si");

	const auto &c_m1d = config.getParameter<edm::ParameterSet>("matching_1d");
	matching_1d_reference_datasets = c_m1d.getParameter<vector<string>>("reference_datasets");

	for (const auto &p : rp_tags)
	{
		const auto &ps = c_m1d.getParameter<edm::ParameterSet>("rp_" + p.second);
		matching_1d_ranges[p.first] = SelectionRange(ps.getParameter<double>("x_min"), ps.getParameter<double>("x_max"));
		matching_1d_shift_ranges[p.first] = SelectionRange(ps.getParameter<double>("sh_min"), ps.getParameter<double>("sh_max"));
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

	printf("* dataset already aligned\n");
	printf("    aligned = %u\n", aligned);

	printf("\n");
	printf("* alignment parameters\n");
	for (const auto &p : alignment_corrections_x)
		printf("    RP %u: de_x = %.3f mm\n", p.first, p.second);

	printf("\n");
	printf("* cuts\n");
	printf("    n_si = %.3f\n", n_si);
	printf("    cut1: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", cut1_apply, cut1_a, cut1_c, cut1_si);
	printf("    cut2: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", cut2_apply, cut2_a, cut2_c, cut2_si);
	printf("    cut3: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", cut3_apply, cut3_a, cut3_c, cut3_si);
	printf("    cut4: apply = %u, a = %.3f, c = %.3f, si = %.3f\n", cut4_apply, cut4_a, cut4_c, cut4_si);

	printf("\n");
	printf("* 1D matching\n");
	printf("    reference datasets (%lu):\n", matching_1d_reference_datasets.size());
	for (const auto &ds : matching_1d_reference_datasets)
		printf("        %s\n", ds.c_str());
	for (const auto &p : matching_1d_ranges)
	{
		const auto it_sh = matching_1d_shift_ranges.find(p.first);
		printf("    RP %u: x_min = %.3f, x_max = %.3f, sh_min = %.3f, sh_max = %.3f\n",
			p.first, p.second.x_min, p.second.x_max, it_sh->second.x_min, it_sh->second.x_max);
	}

}

//----------------------------------------------------------------------------------------------------

Config cfg;

#endif
