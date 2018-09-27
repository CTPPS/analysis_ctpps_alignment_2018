import root;
import pad_layout;

include "../common.asy";

string topDir = "../../data/phys/";

include "../fills_samples.asy";
InitDataSets();

//----------------------------------------------------------------------------------------------------

string sample = "ZeroBias";

string method = "method y";

int xangles[];
string xangle_refs[];
pen xangle_pens[];
xangles.push(110); xangle_refs.push("data_alig_fill_6228_xangle_110_DS1"); xangle_pens.push(blue);
xangles.push(130); xangle_refs.push("data_alig_fill_6228_xangle_130_DS1"); xangle_pens.push(red);
xangles.push(150); xangle_refs.push("data_alig_fill_6228_xangle_150_DS1"); xangle_pens.push(heavygreen);

int rp_ids[];
string rps[], rp_labels[], rp_dirs[];
real rp_y_min[], rp_y_max[];
rp_ids.push(23); rps.push("L_2_F"); rp_labels.push("L-220-fr"); rp_y_min.push(2); rp_y_max.push(4); rp_dirs.push("sector 45/F");
rp_ids.push(3); rps.push("L_1_F"); rp_labels.push("L-210-fr"); rp_y_min.push(3); rp_y_max.push(5); rp_dirs.push("sector 45/N");
rp_ids.push(103); rps.push("R_1_F"); rp_labels.push("R-210-fr"); rp_y_min.push(3); rp_y_max.push(5); rp_dirs.push("sector 56/N");
rp_ids.push(123); rps.push("R_2_F"); rp_labels.push("R-220-fr"); rp_y_min.push(2); rp_y_max.push(4); rp_dirs.push("sector 56/F");

xSizeDef = 40cm;

yTicksDef = RightTicks(0.5, 0.1);

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

				string f = topDir + dataset + "/" + sample + "/y_alignment_alt.root";

				RootObject results = RootGetObject(f, rp_dirs[rpi] + "/g_results", error=false);
		
				if (!results.valid)
					continue;
		
				real ax[] = {0.};
				real ay[] = {0.};
				results.vExec("GetPoint", 2, ax, ay); real sh_y = ax[0], sh_y_unc = ay[0];

				real x = fdi;
				pen p = xangle_pens[xai];

				if (sh_y_unc > 0 && sh_y_unc < 1)
				{
					draw((x, sh_y), m + p);
					draw((x, sh_y - sh_y_unc)--(x, sh_y + sh_y_unc), p);
				}
			}
		}
	}

	real y_mean = GetMeanVerticalAlignment(rps[rpi]);
	draw((-1, y_mean)--(fill_data.length, y_mean), black);

	limits((-1, rp_y_min[rpi]), (fill_data.length, rp_y_max[rpi]), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
