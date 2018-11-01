import root;
import pad_layout;

include "../common.asy";
include "../io_alignment_format.asy";

string topDir = "../../data/phys/";

include "../fills_samples.asy";
InitDataSets();

//----------------------------------------------------------------------------------------------------

string fn_export = "../../export/collect_alignments.out";
AlignmentResults arc[];
LoadAlignmentResults(fn_export, arc);

string sample_labels[];
//sample_labels.push("ZeroBias");
//sample_labels.push("DoubleEG");
sample_labels.push("SingleMuon");

real mfa = 0.3;

string xangles[];
xangles.push("160");

string sectors[], s_labels[];
real s_y_mins[], s_y_maxs[];
string s_rp_Ns[], s_rp_Fs[];
int s_rp_id_Ns[], s_rp_id_Fs[];
sectors.push("45"); s_labels.push("sector 45"); s_y_mins.push(37.5); s_y_maxs.push(38.5); s_rp_Ns.push("L_1_F"); s_rp_Fs.push("L_2_F"); s_rp_id_Ns.push(3); s_rp_id_Fs.push(23);
sectors.push("56"); s_labels.push("sector 56"); s_y_mins.push(38.8); s_y_maxs.push(39.8); s_rp_Ns.push("R_1_F"); s_rp_Fs.push("R_2_F"); s_rp_id_Ns.push(103); s_rp_id_Fs.push(123);

yTicksDef = RightTicks(0.2, 0.1);

xSizeDef = 40cm;

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

// TODO
/*
AddToLegend("(" + sample + ")");
AddToLegend(format("(xangle %u)", xangle));

for (int mi : abs_methods.keys)
	AddToLegend(abs_methods[mi], mCi + 3pt + am_pens[mi]);

AddToLegend("method rel (fs)", mSq+4pt+magenta);

AttachLegend();
*/

//----------------------------------------------------------------------------------------------------

for (int si : sectors.keys)
{
	write(sectors[si]);

	NewRow();

	NewPad("fill", "$x_N - x_F\ung{mm}$");
	
	for (int fdi : fill_data.keys)
	{
		write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 

		for (int dsi : fill_data[fdi].datasets.keys)
		{
			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;

			real x = fdi;

			for (int sai : sample_labels.keys)
			{
				for (int xai : xangles.keys)
				{
					if (fill_data[fdi].datasets[dsi].xangle != xangles[xai])
						continue;

					// relative methods
					{
						string f = topDir + dataset + "/" + sample_labels[sai] + "/x_alignment_relative.root";	
						RootObject obj = RootGetObject(f, "sector " + sectors[si] + "/g_results", error = false);

						if (!obj.valid)
							continue;
						
						real ax[] = { 0. };
						real ay[] = { 0. };
						
						obj.vExec("GetPoint", 1, ax, ay); real b = ax[0], b_unc = ay[0];
						obj.vExec("GetPoint", 2, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

						if (b_fs == b_fs && b_fs_unc == b_fs_unc && b_fs > 1.)
						{
							pen p = black;
							draw((x, b_fs), mCi+3pt + p);
							draw((x, b_fs - b_fs_unc)--(x, b_fs + b_fs_unc), p);
						}
					}
				}
			}
		}

		// plot export data
		for (int ri : arc.keys)
		{
			string label = format("fill %u", fill);
			if (arc[ri].label == label)
			{
				if (!arc[ri].results.initialized(s_rp_id_Ns[si]) || !arc[ri].results.initialized(s_rp_id_Fs[si]))
					continue;

				AlignmentResult r_N = arc[ri].results[s_rp_id_Ns[si]];
				AlignmentResult r_F = arc[ri].results[s_rp_id_Fs[si]];

				draw((fdi, - r_F.sh_x + r_N.sh_x), mCi + 3pt + red);
			}
		}
	}

	real y_mean = GetMeanHorizontalRelativeAlignment(sectors[si]);
	draw((-1, y_mean)--(fill_data.length, y_mean), black);

	//xlimits(-1, fill_data.length, Crop);
	limits((-1, s_y_mins[si]), (fill_data.length, s_y_maxs[si]), Crop);

	AttachLegend("{\SetFontSizesXX " + s_labels[si] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
