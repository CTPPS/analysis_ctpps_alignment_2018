import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

InitDataSets();

//----------------------------------------------------------------------------------------------------

pen p_meth_fit = red;
pen p_meth_s_curve = blue;

yTicksDef = RightTicks(0.2, 0.1);

xSizeDef = x_size_fill_cmp;

xTicksDef = LeftTicks(rotate(90)*Label(""), FillTickLabels, Step=1, step=0);


//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("version = " + version_phys);

AddToLegend("sample = " + sample);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);

AddToLegend("method fit", mCi+2pt + p_meth_fit);
AddToLegend("method s-curve", mCi+2pt + p_meth_s_curve);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int ai : arms.keys)
{
	write(arms[ai]);

	NewRow();

	NewPad("fill", "$y_F - y_N\ung{mm}$");
	
	for (int fdi : fill_data.keys)
	{
		write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 

		for (int dsi : fill_data[fdi].datasets.keys)
		{
			if (fill_data[fdi].datasets[dsi].xangle != xangle)
				continue;

			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;

			real x = fdi;
			
			real ax[] = {0.};
			real ay[] = {0.};

			// "fit" method
			{
				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/y_alignment.root";
				RootObject results_N = RootGetObject(f, a_nr_rps[ai] + "/g_results", error = false);
				RootObject results_F = RootGetObject(f, a_fr_rps[ai] + "/g_results", error = false);
		
				if (results_N.valid && results_F.valid)
				{
					// fit with slope free
					//results_N.vExec("GetPoint", 2, ax, ay); real b_N = ax[0], b_N_unc = ay[0];
					//results_F.vExec("GetPoint", 2, ax, ay); real b_F = ax[0], b_F_unc = ay[0];

					// fit with slope fixed
					results_N.vExec("GetPoint", 3, ax, ay); real b_N = ax[0], b_N_unc = ay[0];
					results_F.vExec("GetPoint", 3, ax, ay); real b_F = ax[0], b_F_unc = ay[0];

					real diff = b_F - b_N;
					real diff_unc = sqrt(b_F_unc*b_F_unc + b_N_unc*b_N_unc);

					bool valid = (b_N_unc > 0 && b_F_unc > 0);

					if (valid)
					{
						draw((x, diff), m + p_meth_fit);
						draw((x, diff - diff_unc)--(x, diff + diff_unc), p_meth_fit);
					}
				}
			}

			// get "s curve" method result
			{
				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/y_alignment_alt.root";
				RootObject results_N = RootGetObject(f, a_sectors[ai] + "/N/g_results", error=false);
				RootObject results_F = RootGetObject(f, a_sectors[ai] + "/F/g_results", error=false);
		
				if (results_N.valid && results_F.valid)
				{
					results_N.vExec("GetPoint", 2, ax, ay); real sh_y_N = ax[0], sh_y_N_unc = ay[0];
					results_F.vExec("GetPoint", 2, ax, ay); real sh_y_F = ax[0], sh_y_F_unc = ay[0];

					real diff = sh_y_F - sh_y_N;
					real diff_unc = sqrt(sh_y_F_unc*sh_y_F_unc + sh_y_N_unc*sh_y_N_unc);

					bool valid = (sh_y_N_unc > 0 && sh_y_F_unc > 0);

					if (valid)
					{
						draw((x, diff), m + p_meth_s_curve);
						draw((x, diff - diff_unc)--(x, diff + diff_unc), p_meth_s_curve);
					}
				}
			}
		}
	}

	real y_mean = GetMeanVerticalRelativeAlignment(a_sectors[ai]);

	real y_min = y_mean - 1.5;
	real y_max = y_mean + 1.5;

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + a_labels[ai] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
