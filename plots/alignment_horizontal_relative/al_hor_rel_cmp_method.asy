import root;
import pad_layout;

include "../common.asy";

string topDir = "../../data/phys/";

include "../fills_samples.asy";
InitDataSets();

//----------------------------------------------------------------------------------------------------

string sample = "DoubleEG";

real mfa = 0.3;

string abs_methods[];
pen am_pens[];
abs_methods.push("method x"); am_pens.push(blue);
abs_methods.push("method y"); am_pens.push(red);
abs_methods.push("method o"); am_pens.push(heavygreen);

//int xangle = 120;
//string ref_label = "data_alig_fill_6228_xangle_120_DS1";

int xangle = 150;
string ref_label = "data_alig_fill_6228_xangle_150_DS1";

string sectors[], s_labels[];
real s_y_mins[], s_y_maxs[], s_y_cens[];
string s_rp_Ns[], s_rp_Fs[];
sectors.push("45"); s_labels.push("sector 45"); s_y_mins.push(38.0); s_y_maxs.push(39.0); s_y_cens.push(+0.008); s_rp_Ns.push("L_1_F"); s_rp_Fs.push("L_2_F");
sectors.push("56"); s_labels.push("sector 56"); s_y_mins.push(38.8); s_y_maxs.push(39.8); s_y_cens.push(-0.012); s_rp_Ns.push("R_1_F"); s_rp_Fs.push("R_2_F");

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

for (int mi : abs_methods.keys)
	AddToLegend(abs_methods[mi], mCi + 3pt + am_pens[mi]);

AddToLegend("method rel (fs)", mSq+4pt+magenta);

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

			real x = fdi;

			// absolute methods
			for (int mi : abs_methods.keys)
			{
				string method = abs_methods[mi];

				RootObject obj_N, obj_F;

				if (method == "method x" || method == "method y")
				{
					string f = topDir + dataset + "/" + sample + "/match.root";	
					obj_N = RootGetObject(f, ref_label + "/" + s_rp_Ns[si] + "/" + method + "/g_results", error = false);
					obj_F = RootGetObject(f, ref_label + "/" + s_rp_Fs[si] + "/" + method + "/g_results", error = false);
				}

				if (method == "method o")
				{
					string f = topDir + dataset + "/" + sample + "/x_alignment_meth_o.root";	
					obj_N = RootGetObject(f, ref_label + "/" + s_rp_Ns[si] + "/g_results", error = false);
					obj_F = RootGetObject(f, ref_label + "/" + s_rp_Fs[si] + "/g_results", error = false);
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

					bool pointValid = (c_N == c_N && c_F == c_F && c_N_unc == c_N_unc && c_F_unc == c_F_unc);

					real c_FN = - (c_F - c_N);
					real c_FN_unc = sqrt(c_F_unc*c_F_unc + c_N_unc*c_N_unc);

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
				string f = topDir + dataset + "/" + sample + "/x_alignment_relative.root";	
				RootObject obj = RootGetObject(f, "sector " + sectors[si] + "/g_results", error = false);

				if (!obj.valid)
					continue;
				
				real ax[] = { 0. };
				real ay[] = { 0. };
				
				obj.vExec("GetPoint", 1, ax, ay); real b = ax[0], b_unc = ay[0];
				obj.vExec("GetPoint", 2, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

				if (b_fs == b_fs && b_fs_unc == b_fs_unc && b_fs > 1.)
				{
					pen p = magenta;
					draw((x, b_fs), mSq+4pt + p);
					draw((x, b_fs - b_fs_unc)--(x, b_fs + b_fs_unc), p);
				}
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
