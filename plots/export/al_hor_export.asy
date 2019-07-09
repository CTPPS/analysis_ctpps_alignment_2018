import root;
import pad_layout;

include "../common.asy";
include "../io_alignment_format.asy";

string topDir = "../../data/phys/";

//----------------------------------------------------------------------------------------------------

string fn_export = "../../export/collect_alignments.out";
AlignmentResults arc[];
LoadAlignmentResults(fn_export, arc);

string sample_labels[];
//sample_labels.push("ZeroBias");
//sample_labels.push("DoubleEG");
sample_labels.push("SingleMuon");

real sfa = 0.3;

string method = "method o";

string xangles[];
string ref_labels[];
xangles.push("160"); ref_labels.push("data_alig_fill_6554_xangle_160_beta_0.30_DS1");

int rp_ids[];
string rps[], rp_labels[];
real rp_shift_m[];
rp_ids.push(23); rps.push("L_2_F"); rp_labels.push("L-220-fr"); rp_shift_m.push(-42.05);
rp_ids.push(3); rps.push("L_1_F"); rp_labels.push("L-210-fr"); rp_shift_m.push(-3.7);
rp_ids.push(103); rps.push("R_1_F"); rp_labels.push("R-210-fr"); rp_shift_m.push(-2.75);
rp_ids.push(123); rps.push("R_2_F"); rp_labels.push("R-220-fr"); rp_shift_m.push(-42.05);

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
AddToLegend("(" + method + ")");
AddToLegend(format("(xangle %u)", xangle));

for (int sai : sample_labels.keys)
{
	AddToLegend(sample_labels[sai], sample_pens[sai]);
}
*/

AttachLegend();

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
{
	write(rps[rpi]);

	NewRow();

	NewPad("fill", "horizontal shift$\ung{mm}$");
	
	for (int fdi : fill_data.keys)
	{
		write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 
		int rp_id = rp_ids[rpi];

		for (int dsi : fill_data[fdi].datasets.keys)
		{
			string dataset = fill_data[fdi].datasets[dsi].tag;

			write("        " + dataset);
	
			mark m = mCi+3pt;
	
			for (int sai : sample_labels.keys)
			{
				for (int xai : xangles.keys)
				{
					if (fill_data[fdi].datasets[dsi].xangle != xangles[xai])
						continue;

					string f = topDir + dataset + "/" + sample_labels[sai] + "/x_alignment_meth_o.root";	
					RootObject obj = RootGetObject(f, ref_labels[xai] + "/" + rps[rpi] + "/g_results", error = false);
		
					if (!obj.valid)
						continue;
		
					real ax[] = { 0. };
					real ay[] = { 0. };
					obj.vExec("GetPoint", 0, ax, ay); real bsh = ax[0], bsh_unc = ay[0];

					real x = fdi;
					if (sample_labels.length > 1)
						x += sai * sfa / (sample_labels.length - 1) - sfa/2;

					bool pointValid = (bsh == bsh && bsh_unc == bsh_unc && fabs(bsh) > 0.01);
		
					pen p = black;
		
					if (pointValid)
					{
						draw((x, bsh), m + p);
						draw((x, bsh-bsh_unc)--(x, bsh+bsh_unc), p);
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
				if (!arc[ri].results.initialized(rp_ids[rpi]))
					continue;

				AlignmentResult r = arc[ri].results[rp_ids[rpi]];
				draw((fdi, r.sh_x), mCi + 3pt + red);
			}
		}
	}

	real y_mean = GetMeanHorizontalAlignment(rps[rpi]);
	draw((-1, y_mean)--(fill_data.length, y_mean), black);

	//xlimits(-1, fill_data.length, Crop);
	limits((-1, y_mean-1), (fill_data.length, y_mean+1), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

GShipout(hSkip=5mm, vSkip=1mm);
