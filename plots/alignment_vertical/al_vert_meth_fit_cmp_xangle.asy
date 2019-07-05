import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

real xfa = 0.3;

yTicksDef = RightTicks(0.2, 0.1);

xSizeDef = x_size_fill_cmp;

xTicksDef = LeftTicks(rotate(90)*Label(""), FillTickLabels, Step=1, step=0);

//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("version = " + version_phys);
AddToLegend("sample = " + sample);

for (int cfgi : cfg_xangles.keys)
	AddToLegend("xangle = " + cfg_xangles[cfgi] + ", beta = " + cfg_betas[cfgi], cfg_pens[cfgi]);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
{
	write(rps[rpi]);

	NewRow();

	NewPad("fill", "vertical shift $\ung{mm}$");

	for (int fdi : fill_data.keys)
	{
		write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 

		for (int dsi : fill_data[fdi].datasets.keys)
		{
			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;

			for (int cfgi : cfg_xangles.keys)
			{
				if (fill_data[fdi].datasets[dsi].xangle != cfg_xangles[cfgi])
					continue;

				if (fill_data[fdi].datasets[dsi].beta != cfg_betas[cfgi])
					continue;

				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/y_alignment.root";	
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
				if (cfg_xangles.length > 1)
					x += cfgi * xfa / (cfg_xangles.length - 1) - xfa/2;

				pen p = cfg_pens[cfgi];

				{
					draw((x, b_fs), m + p);
					draw((x, b_fs - b_fs_unc)--(x, b_fs + b_fs_unc), p);
				}
			}
		}
	}

	real y_mean = GetMeanVerticalAlignment(rps[rpi]);

	real y_min = y_mean - 1.5;
	real y_max = y_mean + 1.5;

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
