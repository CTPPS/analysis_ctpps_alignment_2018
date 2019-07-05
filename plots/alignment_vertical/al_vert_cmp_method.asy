import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

pen p_meth_fit = red;
pen p_meth_fit_sl_fixed = heavygreen;
pen p_meth_s_curve = blue;

real sfa = 0.3;

xSizeDef = x_size_fill_cmp;

yTicksDef = RightTicks(0.5, 0.1);

xTicksDef = LeftTicks(rotate(90)*Label(""), FillTickLabels, Step=1, step=0);

//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("version = " + version_phys);
AddToLegend("ref = " + replace(ref, "_", "\_"));

AddToLegend("sample = " + sample);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);

AddToLegend("method ``fit''", mCi+3pt+p_meth_fit);
AddToLegend("method ``fit'' (slope fixed)", mCi+3pt+p_meth_fit_sl_fixed);
AddToLegend("method ``s-curve''", mCi+3pt+p_meth_s_curve);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
{
	NewRow();

	write(rps[rpi]);

	NewPad("fill", "vertical shift $\ung{mm}$");

	for (int fdi : fill_data.keys)
	{
		write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 

		for (int dsi : fill_data[fdi].datasets.keys)
		{
			if (fill_data[fdi].datasets[dsi].xangle != xangle)
				continue;

			if (fill_data[fdi].datasets[dsi].beta != beta)
				continue;

			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;

			{
				real x = fdi;

				mark m = mCi+3pt;

				// "fit" method
				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/y_alignment.root";
				RootObject results = RootGetObject(f, rps[rpi] + "/g_results", error = false);
		
				if (results.valid)
				{
					real ax[] = {0.};
					real ay[] = {0.};
					results.vExec("GetPoint", 0, ax, ay); real sh_x = ax[0];
					results.vExec("GetPoint", 1, ax, ay); real a = ax[0], a_unc = ay[0];
					results.vExec("GetPoint", 2, ax, ay); real b = ax[0], b_unc = ay[0];
					results.vExec("GetPoint", 3, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

					draw((x, b), m + p_meth_fit);
					draw((x, b - b_unc)--(x, b + b_unc), p_meth_fit);

					draw((x, b_fs), m + p_meth_fit_sl_fixed);
					draw((x, b_fs - b_fs_unc)--(x, b_fs + b_fs_unc), p_meth_fit_sl_fixed);
				}

				// "s curve" method result
				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/y_alignment_alt.root";
				RootObject results = RootGetObject(f, rp_dirs[rpi] + "/g_results", error=false);
		
				if (results.valid)
				{
					real ax[] = {0.};
					real ay[] = {0.};
					results.vExec("GetPoint", 2, ax, ay); real sh_y = ax[0], sh_y_unc = ay[0];

					bool valid = (sh_y_unc > 0 && sh_y_unc < 1);

					if (valid)
					{
						draw((x, sh_y), m + p_meth_s_curve);
						draw((x, sh_y - sh_y_unc)--(x, sh_y + sh_y_unc), p_meth_s_curve);
					}
				}
			}
		}
	}

	real y_mean = GetMeanVerticalAlignment(rps[rpi]);

	real y_min = y_mean-1.5;
	real y_max = y_mean+1.5;

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
