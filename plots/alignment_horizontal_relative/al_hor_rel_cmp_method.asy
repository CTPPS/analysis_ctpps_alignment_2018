import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

real mfa = 0.3;

string abs_methods[];
pen am_pens[];
//abs_methods.push("method x"); am_pens.push(blue);
//abs_methods.push("method y"); am_pens.push(red);
abs_methods.push("method o"); am_pens.push(heavygreen);

yTicksDef = RightTicks(0.2, 0.1);

xSizeDef = x_size_fill_cmp;

xTicksDef = LeftTicks(rotate(90)*Label(""), FillTickLabels, Step=1, step=0);

//----------------------------------------------------------------------------------------------------

NewPad(false, 1, 1);

AddToLegend("version = " + version_phys);
AddToLegend("ref = " + replace(ref, "_", "\_"));

AddToLegend("sample = " + sample);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);

for (int mi : abs_methods.keys)
	AddToLegend(abs_methods[mi], mCi + 3pt + am_pens[mi]);

AddToLegend("method rel (fs)", mSq+4pt+magenta);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int ai : arms.keys)
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
			if (fill_data[fdi].datasets[dsi].xangle != xangle)
				continue;

			if (fill_data[fdi].datasets[dsi].beta != beta)
				continue;

			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;

			real x = fdi;

			// absolute methods
			for (int mi : abs_methods.keys)
			{
				string method = abs_methods[mi];

				RootObject obj_N, obj_F;

				if (method == "method x" || method == "method y")
				{
					string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/match.root";
					obj_N = RootGetObject(f, ref + "/" + a_nr_rps[ai] + "/" + method + "/g_results", error = false);
					obj_F = RootGetObject(f, ref + "/" + a_fr_rps[ai] + "/" + method + "/g_results", error = false);
				}

				if (method == "method o")
				{
					string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/x_alignment_meth_o.root";
					obj_N = RootGetObject(f, ref + "/" + a_nr_rps[ai] + "/g_results", error = false);
					obj_F = RootGetObject(f, ref + "/" + a_fr_rps[ai] + "/g_results", error = false);
				}

				real ax[] = { 0. };
				real ay[] = { 0. };

				if (obj_N.valid && obj_F.valid)
				{
					real c_N = -inf, c_N_unc = -inf;
					real c_F = -inf, c_F_unc = -inf;

					if (method == "method x" || method == "method y")
					{
						obj_N.vExec("GetPoint", 0, ax, ay); c_N = ay[0];
						obj_N.vExec("GetPoint", 1, ax, ay); c_N_unc = ay[0];

						obj_F.vExec("GetPoint", 0, ax, ay); c_F = ay[0];
						obj_F.vExec("GetPoint", 1, ax, ay); c_F_unc = ay[0];
					}

					if (method == "method o")
					{
						obj_N.vExec("GetPoint", 0, ax, ay); c_N = ax[0]; c_N_unc = ay[0];
						obj_F.vExec("GetPoint", 0, ax, ay); c_F = ax[0]; c_F_unc = ay[0];
					}

					real c_FN = - (c_F - c_N);
					real c_FN_unc = sqrt(c_F_unc*c_F_unc + c_N_unc*c_N_unc);

					bool pointValid = (c_N == c_N && c_F == c_F && c_N_unc == c_N_unc && c_F_unc == c_F_unc && c_FN_unc < 1);

					pen p = am_pens[mi];
	
					if (pointValid)
					{
						draw((x, c_FN), m + p);
						draw((x, c_FN - c_FN_unc)--(x, c_FN + c_FN_unc), p);
					}
				}
			}

			// relative methods
			{
				string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/x_alignment_relative.root";
				RootObject obj = RootGetObject(f, a_sectors[ai] + "/g_results", error = false);

				if (!obj.valid)
					continue;
				
				real ax[] = { 0. };
				real ay[] = { 0. };
				
				obj.vExec("GetPoint", 2, ax, ay); real b = ax[0], b_unc = ay[0];
				obj.vExec("GetPoint", 3, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

				if (b_fs == b_fs && b_fs_unc == b_fs_unc && b_fs > 1.)
				{
					pen p = magenta;
					draw((x, b_fs), mSq+4pt + p);
					draw((x, b_fs - b_fs_unc)--(x, b_fs + b_fs_unc), p);
				}
			}
		}
	}

	real y_mean = GetMeanHorizontalRelativeAlignment(a_sectors[ai]);
	draw((-1, y_mean)--(fill_data.length, y_mean), black);

	real y_min = y_mean - 0.5;
	real y_max = y_mean + 1.0;

	DrawFillMarkers(y_min, y_max);

	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + a_labels[ai] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
