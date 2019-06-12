import root;
import pad_layout;

include "../common.asy";

string topDir = "../../data/phys-version1/";

include "../fills_samples.asy";
InitDataSets();

//----------------------------------------------------------------------------------------------------

string sample = "ALL";

int xangles[];
string xangle_refs[];
pen xangle_pens[];
xangles.push(120); xangle_refs.push("data_alig-may-version3-aligned_fill_5685_xangle_120_DS1"); xangle_pens.push(blue);
xangles.push(150); xangle_refs.push("data_alig-may-version3-aligned_fill_5685_xangle_150_DS1"); xangle_pens.push(heavygreen);

int rp_ids[];
string rps[], rp_labels[];
real rp_y_min[], rp_y_max[];
rp_ids.push(23); rps.push("L_2_F"); rp_labels.push("L-220-fr"); rp_y_min.push(3); rp_y_max.push(4);
rp_ids.push(3); rps.push("L_1_F"); rp_labels.push("L-210-fr"); rp_y_min.push(3); rp_y_max.push(4);
rp_ids.push(103); rps.push("R_1_F"); rp_labels.push("R-210-fr"); rp_y_min.push(2.8); rp_y_max.push(3.8);
rp_ids.push(123); rps.push("R_2_F"); rp_labels.push("R-220-fr"); rp_y_min.push(2.8); rp_y_max.push(3.8);

xSizeDef = 40cm;

yTicksDef = RightTicks(0.1, 0.05);

//----------------------------------------------------------------------------------------------------

string TickLabels(real x)
{
	if (x >=0 && x < fill_data.length)
	{
		return format("%i", fill_data[(int) x].fill);
	} else {
		return "";
	}
}

xTicksDef = LeftTicks(rotate(90)*Label(""), TickLabels, Step=1, step=0);

//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("(" + sample + ")");

for (int xai : xangles.keys)
{
	AddToLegend(format("xangle %u", xangles[xai]), xangle_pens[xai]);
}

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
{
	write(rps[rpi]);

	//if (rpi == 2)
		NewRow();

	NewPad("fill", "vertical shift $\ung{mm}$");

	for (int fdi : fill_data.keys)
	{
		write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 
		int rp_id = rp_ids[rpi];

		for (int dsi : fill_data[fdi].datasets.keys)
		{
			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;

			for (int xai : xangles.keys)
			{
				if (fill_data[fdi].datasets[dsi].xangle != xangles[xai])
					continue;

				string f = topDir + dataset + "/" + sample + "/y_alignment.root";

				RootObject results = RootGetObject(f, rps[rpi] + "/g_results", error = false);
		
				if (!results.valid)
					continue;
		
				real ax[] = {0.};
				real ay[] = {0.};
				results.vExec("GetPoint", 0, ax, ay); real sh_x = ax[0];
				results.vExec("GetPoint", 1, ax, ay); real a = ax[0], a_unc = ay[0];
				results.vExec("GetPoint", 2, ax, ay); real b = ax[0], b_unc = ay[0];
				results.vExec("GetPoint", 3, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

				real x = fdi;
				pen p = xangle_pens[xai];

				{
					draw((x, b_fs), m + p);
					draw((x, b_fs - b_fs_unc)--(x, b_fs + b_fs_unc), p);
				}
			}
		}
	}

	limits((-1, rp_y_min[rpi]), (fill_data.length, rp_y_max[rpi]), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
