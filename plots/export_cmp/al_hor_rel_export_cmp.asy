import root;
import pad_layout;

include "../common.asy";
include "../io_alignment_format.asy";

include "../fills_samples.asy";
InitDataSets();

include "result_list.asy";

string sectors[], s_labels[];
real s_y_mins[], s_y_maxs[];
string s_rp_Ns[], s_rp_Fs[];
int s_rp_id_Ns[], s_rp_id_Fs[];
sectors.push("45"); s_labels.push("sector 45"); s_y_mins.push(37.6); s_y_maxs.push(38.6); s_rp_Ns.push("L_1_F"); s_rp_Fs.push("L_2_F"); s_rp_id_Ns.push(3); s_rp_id_Fs.push(23);
sectors.push("56"); s_labels.push("sector 56"); s_y_mins.push(38.9); s_y_maxs.push(39.8); s_rp_Ns.push("R_1_F"); s_rp_Fs.push("R_2_F"); s_rp_id_Ns.push(103); s_rp_id_Fs.push(123);

yTicksDef = RightTicks(0.100, 0.050);

xSizeDef = 60cm;

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

AlignmentResults f_arc[][];
for (int fi : files.keys)
{
	AlignmentResults arc[];
	LoadAlignmentResults(files[fi], arc);
	f_arc[fi] = arc;
}

for (int si : sectors.keys)
{
	write(sectors[si]);

	NewRow();

	NewPad("fill", "$x_N - x_F\ung{mm}$");
	
	for (int fdi : fill_data.keys)
	{
		//write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 

		for (int fi : files.keys)
		{
			for (int ri : f_arc[fi].keys)
			{
				string label = format("fill %u", fill);
				if (f_arc[fi][ri].label == label)
				{
					AlignmentResult r_N = f_arc[fi][ri].results[s_rp_id_Ns[si]];
					AlignmentResult r_F = f_arc[fi][ri].results[s_rp_id_Fs[si]];

					draw((fdi, - r_F.sh_x + r_N.sh_x), mCi + 3pt + f_pens[fi]);
				}
			}
		}
	}

	real y_mean = GetMeanHorizontalRelativeAlignment(sectors[si]);
	//draw((-1, y_mean)--(fill_data.length, y_mean), black);

	limits((-1, s_y_mins[si]), (fill_data.length, s_y_maxs[si]), Crop);

	AttachLegend("{\SetFontSizesXX " + s_labels[si] + "}");
}

//----------------------------------------------------------------------------------------------------

NewPad(false);
for (int fi : files.keys)
	AddToLegend(f_labels[fi], mCi+3pt+f_pens[fi]);
AttachLegend();

//----------------------------------------------------------------------------------------------------

GShipout("al_hor_rel_export_cmp", hSkip=5mm, vSkip=1mm);
