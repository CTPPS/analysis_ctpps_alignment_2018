#include <cstdio>
#include <cstring>
#include <cmath>

#include <string>
#include <map>
#include <set>

using namespace std;


//----------------------------------------------------------------------------------------------------

struct Key
{
	signed int xangle;
	double beta_st;

	bool Selected() const
	{
		if ( (xangle == 130 && fabs(beta_st - 0.25) < 1e-5)
				//|| (xangle == 130 && fabs(beta_st - 0.27) < 1e-5)
				|| (xangle == 130 && fabs(beta_st - 0.30) < 1e-5)
				//|| (xangle == 140 && fabs(beta_st - 0.30) < 1e-5)
				|| (xangle == 160 && fabs(beta_st - 0.30) < 1e-5) )
			return true;
		return false;
	}
};

bool operator <(const Key &a, const Key &b)
{
	if (a.xangle < b.xangle)
		return true;

	if (a.xangle > b.xangle)
		return false;

	if (a.beta_st < b.beta_st)
		return true;

	return false;
}

//----------------------------------------------------------------------------------------------------

struct MinMax
{
	unsigned int v_min=1000000, v_max=0;

	void Update(unsigned int v)
	{
		v_min = min(v_min, v);
		v_max = max(v_max, v);
	}
};

//----------------------------------------------------------------------------------------------------

struct Stat
{
	signed int count = 0;
	set<unsigned int> fills;
	map<unsigned int, map<unsigned int, MinMax>> fill_run_ls;
};

Stat global_data;
map<Key, Stat> data_collection;

set<unsigned int> fills;
set<unsigned int> fills_selected;

//----------------------------------------------------------------------------------------------------

void Load(const string &fn)
{
	FILE *f = fopen(fn.c_str(), "r");
	if (!f)
	{
		printf("ERROR: cannot open file \"%s\"\n", fn.c_str());
		return;
	}

	char line[200];
	while (fgets(line, 200, f))
	{
		//printf("%s\n", line);

		signed int fill, run, ls, xangle;
		double beta_st;

		char *p = strtok(line+1, ",");
		int idx = 0;
		while (p != NULL)
		{
			if (idx == 0) fill = atoi(p);
			if (idx == 1) run = atoi(p);
			if (idx == 2) ls = atoi(p);
			if (idx == 3) xangle = atoi(p);
			if (idx == 4) beta_st = atof(p);

			idx++;
			p = strtok(NULL, ",");
		}

		//printf("    %u, %u, %u, %u, %.3f\n", fill, run, ls, xangle, beta_st);

		if (xangle < 0)
			continue;
		if (beta_st < 0.2 || beta_st > 0.4)
			continue;

		Key key = {xangle, beta_st};
		Stat &stat = data_collection[key];
		stat.count++;
		stat.fills.insert(fill);
		stat.fill_run_ls[fill][run].Update(ls);

		global_data.fill_run_ls[fill][run].Update(ls);

		fills.insert(fill);
		
		if (key.Selected())
			fills_selected.insert(fill);
	}

	fclose(f);
}

//----------------------------------------------------------------------------------------------------

void WriteJSON(const string &fn, const map<unsigned int, MinMax> &data)
{
	FILE *f_out = fopen(fn.c_str(), "w");

	fprintf(f_out, "{\n");

	bool start = true;
	for (const auto &ri : data)
	{
		if (!start)
			fprintf(f_out, ",\n");
		start = false;

		fprintf(f_out, "  \"%u\": [[%u, %u]]", ri.first, ri.second.v_min, ri.second.v_max);
	}

	fprintf(f_out, "\n}\n");

	fclose(f_out);
}

//----------------------------------------------------------------------------------------------------

int main()
{
	Load("mapping/output_6570_6670.txt");
	Load("mapping/output_6671_6870.txt");
	Load("mapping/output_6871_6970.txt");
	Load("mapping/output_6971_7070.txt");
	Load("mapping/output_7071_7188.txt");
	Load("mapping/output_7213_7221.txt");
	Load("mapping/output_7234_7240.txt");
	Load("mapping/output_7242_7256.txt");
	Load("mapping/output_7259_7265.txt");
	Load("mapping/output_7266.txt");
	Load("mapping/output_7270.txt");
	Load("mapping/output_7271_7299.txt");
	Load("mapping/output_7300_7334.txt");

	printf("* fills: total=%lu, selected=%lu\n", fills.size(), fills_selected.size());

	// save per-condition JSONs
	printf("\n");
	for (const auto &p : data_collection)
	{
		if (p.second.count < 10)
			continue;

		printf("xangle=%3i, beta_st=%5.3f: lumisections=%5u, fills=%3lu\n", p.first.xangle, p.first.beta_st, p.second.count, p.second.fills.size());

		if (p.first.Selected())
		{
			for (const auto &fi : p.second.fill_run_ls)
			{
				char fn[200];
				sprintf(fn, "json/fill_%u_xangle_%i_betast_%.2f.json", fi.first, p.first.xangle, p.first.beta_st);

				WriteJSON(fn, fi.second);
			}
		}
	}

	// save per-fill JSONs
	printf("\n");
	for (const auto &p : global_data.fill_run_ls)
	{
		char fn[200];
		sprintf(fn, "json/fill_%u_xangle_ALL_betast_ALL.json", p.first);

		WriteJSON(fn, p.second);
	}

	return 0;
}
