import root;
import pad_layout;

string topDir = "../../data/phys/";

include "../fills_samples.asy";
InitDataSets();

//----------------------------------------------------------------------------------------------------

string sample_labels[];
pen sample_pens[];
sample_labels.push("ZeroBias"); sample_pens.push(blue);
sample_labels.push("DoubleEG"); sample_pens.push(red);
sample_labels.push("SingleMuon"); sample_pens.push(heavygreen);

int xangle = 150;

real sfa = 0.3;

string sectors[], s_labels[];
real s_y_mins[], s_y_maxs[], s_y_cens[];
sectors.push("45"); s_labels.push("sector 45"); s_y_mins.push(-0.02); s_y_maxs.push(+0.02); s_y_cens.push(+0.008);
sectors.push("56"); s_labels.push("sector 56"); s_y_mins.push(-0.03); s_y_maxs.push(+0.01); s_y_cens.push(-0.012);

xSizeDef = 40cm;

//yTicksDef = RightTicks(0.02, 0.01);

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

AddToLegend(format("xangle = %u", xangle));

for (int sai : sample_labels.keys)
{
	AddToLegend(sample_labels[sai], sample_pens[sai]);
}

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int si : sectors.keys)
{
	write(sectors[si]);

	NewRow();

	NewPad("fill", "slope$\ung{rad}$");

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

			for (int sai : sample_labels.keys)
			{
				string f = topDir + dataset + "/" + sample_labels[sai] + "/x_alignment_relative.root";

				RootObject obj = RootGetObject(f, "sector " + sectors[si] + "/p_x_diffFN_vs_x_N|ff", error = false);
		
				if (!obj.valid)
					continue;
		
				real x = fdi;

				real y = obj.rExec("GetParameter", 1);
				real y_unc = obj.rExec("GetParError", 1);

				pen p = sample_pens[sai];

				{
					draw((x, y), m + p);
					draw((x, y-y_unc)--(x, y+y_unc), p);
				}
			}
		}
	}

	limits((-1, s_y_mins[si]), (fill_data.length, s_y_maxs[si]), Crop);

	xaxis(YEquals(s_y_cens[si], false), black+1pt);

	AttachLegend("{\SetFontSizesXX " + s_labels[si] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
