import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

real mfa = 0.3;

string methods[];
pen m_pens[];
//methods.push("method x"); m_pens.push(blue);
methods.push("method y"); m_pens.push(red);
methods.push("method o"); m_pens.push(heavygreen);

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

for (int mi : methods.keys)
	AddToLegend(methods[mi], mCi + 3pt + m_pens[mi]);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
{
	write("* " + rps[rpi]);

	NewRow();

	NewPad("fill", "horizontal shift$\ung{mm}$");

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

			for (int mi : methods.keys)
			{
				string method = methods[mi];

				RootObject obj;

				if (method == "method x" || method == "method y")
				{
					string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/match.root";	
					obj = RootGetObject(f, ref + "/" + rps[rpi] + "/" + method + "/g_results", error = false);
				}

				if (method == "method o")
				{
					string f = topDir + "data/" + version_phys + "/" + dataset + "/" + sample + "/x_alignment_meth_o.root";	
					obj = RootGetObject(f, ref + "/" + rps[rpi] + "/g_results", error = false);
				}

				if (obj.valid)
				{
					real bsh = -inf, bsh_unc = -inf;
					real ax[] = { 0. };
					real ay[] = { 0. };
					if (method == "method x" || method == "method y")
					{
						obj.vExec("GetPoint", 0, ax, ay); bsh = ay[0];
						obj.vExec("GetPoint", 1, ax, ay); bsh_unc = ay[0];
					}
					if (method == "method o")
					{
						obj.vExec("GetPoint", 0, ax, ay); bsh = ax[0]; bsh_unc = ay[0];
					}

					bool pointValid = (bsh == bsh && bsh_unc == bsh_unc && fabs(bsh) > 0.01);
					pen p = m_pens[mi];
	
					if (pointValid)
					{
						draw((x, bsh), m + p);
						draw((x, bsh-bsh_unc)--(x, bsh+bsh_unc), p);
					}
				}
			}
		}
	}

	real y_mean = GetMeanHorizontalAlignment(rps[rpi]);
	//draw((-1, y_mean)--(fill_data.length, y_mean), black);

	real y_min = y_mean - 1.0;
	real y_max = y_mean + 1.0;

	DrawFillMarkers(y_min, y_max);

	//xlimits(-1, fill_data.length, Crop);
	limits((-1, y_min), (fill_data.length, y_max), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
