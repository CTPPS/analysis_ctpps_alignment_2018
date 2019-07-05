import root;
import pad_layout;

string topDir = "../../";

include "../common.asy";

real sfa = 0.3;

xSizeDef = x_size_fill_cmp;

xTicksDef = LeftTicks(rotate(90)*Label(""), FillTickLabels, Step=1, step=0);

yTicksDef = RightTicks(0.02, 0.01);

//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("version = " + version_phys);

for (int cfgi : cfg_xangles.keys)
	AddToLegend("xangle = " + cfg_xangles[cfgi] + ", beta = " + cfg_betas[cfgi], cfg_pens[cfgi]);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
{
	write(rps[rpi]);

	//if (rpi == 2)
		NewRow();

	NewPad("fill", "slope$\ung{rad}$");

	for (int fdi : fill_data.keys)
	{
		string fill = format("%u", fill_data[fdi].fill);

		write(fill);

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

				RootObject obj = RootGetObject(f, rps[rpi] + "/g_y_cen_vs_x|ff", error = false);
		
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

	real y_min = 0.0, y_max = 0.5;
	if (rp_arms[rpi] == "arm0") { y_min = 0.05; y_max = 0.35; }
	if (rp_arms[rpi] == "arm1") { y_min = 0.25; y_max = 0.55; }

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
