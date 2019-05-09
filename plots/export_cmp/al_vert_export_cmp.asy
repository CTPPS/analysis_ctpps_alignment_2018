import root;
import pad_layout;

include "../common.asy";
include "../io_alignment_format.asy";

include "../fills_samples.asy";
InitDataSets();

string files[], f_labels[];
pen f_pens[];

files.push("/afs/cern.ch/work/j/jkaspar/software/ctpps/development/ctpps_initial_proton_reconstruction_CMSSW_10_2_0/CMSSW_10_2_0/src/RecoCTPPS/ProtonReconstruction/data/alignment/2018/collect_alignments_2018_11_02.3.out"); f_labels.push("old"); f_pens.push(blue);
files.push("../../export/fit_alignments_2019_05_09.1.out"); f_labels.push("new"); f_pens.push(red);

int rp_ids[];
string rps[], rp_labels[], rp_dirs[];
real rp_y_min[], rp_y_max[];
rp_ids.push(23); rps.push("L_2_F"); rp_labels.push("L-220-fr"); rp_y_min.push(3); rp_y_max.push(6.0); rp_dirs.push("sector 45/F");
rp_ids.push(3); rps.push("L_1_F"); rp_labels.push("L-210-fr"); rp_y_min.push(3); rp_y_max.push(6.0); rp_dirs.push("sector 45/N");
rp_ids.push(103); rps.push("R_1_F"); rp_labels.push("R-210-fr"); rp_y_min.push(3); rp_y_max.push(6.0); rp_dirs.push("sector 56/N");
rp_ids.push(123); rps.push("R_2_F"); rp_labels.push("R-220-fr"); rp_y_min.push(3); rp_y_max.push(6.0); rp_dirs.push("sector 56/F");

xSizeDef = 60cm;

yTicksDef = RightTicks(0.5, 0.1);

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

for (int rpi : rps.keys)
{
	write(rps[rpi]);

	NewRow();

	NewPad("fill", "vertical shift $\ung{mm}$");

	for (int fdi : fill_data.keys)
	{
		//write(format("    %i", fill_data[fdi].fill));

		int fill = fill_data[fdi].fill; 
		int rp_id = rp_ids[rpi];

		for (int fi : files.keys)
		{
			for (int ri : f_arc[fi].keys)
			{
				string label = format("fill %u", fill);
				if (f_arc[fi][ri].label == label)
				{
					AlignmentResult r = f_arc[fi][ri].results[rp_ids[rpi]];
					draw((fdi, r.sh_y), mCi + 3pt + f_pens[fi]);
				}
			}
		}
	}

	real y_mean = GetMeanVerticalAlignment(rps[rpi]);
	//draw((-1, y_mean)--(fill_data.length, y_mean), black);

	limits((-1, rp_y_min[rpi]), (fill_data.length, rp_y_max[rpi]), Crop);

	AttachLegend("{\SetFontSizesXX " + rp_labels[rpi] + "}");
}

//----------------------------------------------------------------------------------------------------

NewPad(false);
for (int fi : files.keys)
	AddToLegend(f_labels[fi], mCi+3pt+f_pens[fi]);
AttachLegend();

//----------------------------------------------------------------------------------------------------

GShipout("al_vert_export_cmp", hSkip=5mm, vSkip=1mm);
