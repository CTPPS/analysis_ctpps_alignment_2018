import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

real sfa = 0.3;

xSizeDef = x_size_fill_cmp;

yTicksDef = RightTicks(0.1, 0.05);

xTicksDef = LeftTicks(rotate(90)*Label(""), FillTickLabels, Step=1, step=0);

//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("version = " + version_phys);
AddToLegend("sample = " + sample);

for (int cfgi : cfg_xangles.keys)
	AddToLegend("xangle = " + cfg_xangles[cfgi] + ", beta = " + cfg_betas[cfgi], cfg_pens[cfgi]);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int ai : a_sectors.keys)
{
	write(a_sectors[ai]);

	NewRow();

	NewPad("fill", "$x_F - x_N\ung{mm}$");

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

				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/x_alignment_relative.root";
				RootObject obj = RootGetObject(f, a_sectors[ai] + "/g_results", error = false);

				if (!obj.valid)
					continue;

				real ax[] = { 0. };
				real ay[] = { 0. };
				
				obj.vExec("GetPoint", 2, ax, ay); real b = ax[0], b_unc = ay[0];
				obj.vExec("GetPoint", 3, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

				real x = fdi;
				if (cfg_xangles.length > 1)
					x += cfgi * sfa / (cfg_xangles.length - 1) - sfa/2;

				pen p = cfg_pens[cfgi];

				if (b_fs == b_fs && b_fs_unc == b_fs_unc && b_fs > 1.)
				{
					draw((x, b_fs), m + p);
					draw((x, b_fs-b_fs_unc)--(x, b_fs+b_fs_unc), p);
				}
			}
		}
	}

	real y_mean = GetMeanHorizontalRelativeAlignment(a_sectors[ai]);

	real y_min = y_mean - 0.3;
	real y_max = y_mean + 0.6;

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + a_labels[ai] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
