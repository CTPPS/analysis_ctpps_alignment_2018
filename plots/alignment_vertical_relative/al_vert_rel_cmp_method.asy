import root;
import pad_layout;

include "../common.asy";

string topDir = "../../data/phys/";

include "../fills_samples.asy";
InitDataSets();

//----------------------------------------------------------------------------------------------------

pen p_meth_fit = red;
pen p_meth_s_curve = blue;

string sample = "DoubleEG";

int xangle = 150;
string ref_label = "data_alig_fill_6228_xangle_150_DS1";

string sectors[], s_labels[];
real s_y_mins[], s_y_maxs[], s_y_cens[];
string s_rp_Ns[], s_rp_Fs[];
sectors.push("45"); s_labels.push("sector 45"); s_y_mins.push(-1.5); s_y_maxs.push(-0.5); s_y_cens.push(+0.008); s_rp_Ns.push("L_1_F"); s_rp_Fs.push("L_2_F");
sectors.push("56"); s_labels.push("sector 56"); s_y_mins.push(-1.5); s_y_maxs.push(-0.5); s_y_cens.push(-0.012); s_rp_Ns.push("R_1_F"); s_rp_Fs.push("R_2_F");

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

AddToLegend("(" + sample + ")");
AddToLegend(format("(xangle %u)", xangle));

AddToLegend("method fit", mCi+2pt + p_meth_fit);
AddToLegend("method s-curve", mCi+2pt + p_meth_s_curve);

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int si : sectors.keys)
{
	write(sectors[si]);

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
				string f = topDir + dataset + "/" + sample + "/y_alignment.root";
				RootObject results_N = RootGetObject(f, s_rp_Ns[si] + "/g_results", error = false);
				RootObject results_F = RootGetObject(f, s_rp_Fs[si] + "/g_results", error = false);
		
				if (results_N.valid && results_F.valid)
				{
					results_N.vExec("GetPoint", 2, ax, ay); real b_N = ax[0], b_N_unc = ay[0];
					results_F.vExec("GetPoint", 2, ax, ay); real b_F = ax[0], b_F_unc = ay[0];

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
				string f = topDir + dataset + "/" + sample + "/y_alignment_alt.root";
				RootObject results_N = RootGetObject(f, "sector " + sectors[si] + "/N/g_results", error=false);
				RootObject results_F = RootGetObject(f, "sector " + sectors[si] + "/F/g_results", error=false);
		
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

	real y_mean = GetMeanVerticalRelativeAlignment(sectors[si]);
	draw((-1, y_mean)--(fill_data.length, y_mean), black);

	limits((-1, s_y_mins[si]), (fill_data.length, s_y_maxs[si]), Crop);

	AttachLegend("{\SetFontSizesXX " + s_labels[si] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
