import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

real sfa = 0.3;

xSizeDef = x_size_fill_cmp;

yTicksDef = RightTicks(0.002, 0.001);

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

	NewPad("fill", "slope$\ung{rad}$");

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
				RootObject obj = RootGetObject(f, a_sectors[ai] + "/p_x_diffFN_vs_x_N|ff", error = false);

				if (!obj.valid)
					continue;

				real y = obj.rExec("GetParameter", 1);
				real y_unc = obj.rExec("GetParError", 1);

				real x = fdi;
				if (cfg_xangles.length > 1)
					x += cfgi * sfa / (cfg_xangles.length - 1) - sfa/2;

				pen p = cfg_pens[cfgi];

				{
					draw((x, y), m + p);
					draw((x, y-y_unc)--(x, y+y_unc), p);
				}
			}
		}
	}

	real y_min = -0.02;
	real y_max = +0.02;

	if (a_sectors[ai] == "sector 45") { y_min = 0.003; y_max = 0.013; }
	if (a_sectors[ai] == "sector 56") { y_min = -0.018; y_max = -0.008; }

	//if (a_sectors[ai] == "sector 45") { xaxis(YEquals(+0.008, false), black); }
	//if (a_sectors[ai] == "sector 56") { xaxis(YEquals(-0.012, false), black); }

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + a_labels[ai] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
