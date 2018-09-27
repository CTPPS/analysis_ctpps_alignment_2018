import root;
import pad_layout;

include "../common.asy";

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

yTicksDef = RightTicks(0.05, 0.01);

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

	NewPad("fill", "$x_F - x_N\ung{mm}$");

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
				RootObject obj = RootGetObject(f, "sector " + sectors[si] + "/g_results", error = false);

				if (!obj.valid)
					continue;
				
				real ax[] = { 0. };
				real ay[] = { 0. };
				
				obj.vExec("GetPoint", 1, ax, ay); real b = ax[0], b_unc = ay[0];
				obj.vExec("GetPoint", 2, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

				real x = fdi;
				if (sample_labels.length > 1)
					x += sai * sfa / (sample_labels.length - 1) - sfa/2;

				pen p = sample_pens[sai];

				if (b_fs == b_fs && b_fs_unc == b_fs_unc && b_fs > 1.)
				{
					draw((x, b_fs), m + p);
					draw((x, b_fs-b_fs_unc)--(x, b_fs+b_fs_unc), p);
				}
			}
		}
	}

	real y_mean = GetMeanHorizontalRelativeAlignment(sectors[si]);
	draw((-1, y_mean)--(fill_data.length, y_mean), black);

	limits((-1, y_mean - 0.1), (fill_data.length, y_mean + 0.1), Crop);

	AttachLegend("{\SetFontSizesXX " + s_labels[si] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
