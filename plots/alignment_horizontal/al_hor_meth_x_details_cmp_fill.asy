import root;
import pad_layout;

include "../common.asy";

string topDir = "../../data/phys-version1/";

string reference = reference_std;
string datasets[] = datasets_std;

string rps[], rp_labels[];
rps.push("L_2_F"); rp_labels.push("L-220-fr");
rps.push("L_1_F"); rp_labels.push("L-210-fr");
rps.push("R_1_F"); rp_labels.push("R-210-fr");
rps.push("R_2_F"); rp_labels.push("R-220-fr");

ySizeDef = 5cm;

xTicksDef = LeftTicks(3., 1.);

//----------------------------------------------------------------------------------------------------

NewPad();
for (int rpi : rps.keys)
	NewPadLabel(rp_labels[rpi]);

for (int dsi : datasets.keys)
{
	string dataset = datasets[dsi];

	write("* " + dataset);

	NewRow();
	NewPadLabel(replace(dataset, "_", "\_"));

	for (int rpi : rps.keys)
	{
		NewPad("$x\ung{mm}$", "entries (normalised)");
		//currentpad.yTicks = RightTicks(0.5, 0.1);

		string f = topDir + dataset+"/match.root";
		string p_base = reference + "/" + rps[rpi] + "/method x/c_cmp";
		RootObject obj_base = RootGetObject(f, p_base, error=false);
		if (!obj_base.valid)
			continue;

		draw(RootGetObject(f, p_base + "|h_ref_sel"), "d0,eb", black);
		draw(RootGetObject(f, p_base + "|h_test_bef"), "d0,eb", blue);
		draw(RootGetObject(f, p_base + "|h_test_aft"), "d0,eb", red);

		//limits((2, 0), (15, 3.5), Crop);
		xlimits(3, 16, Crop);
	}
}

GShipout(hSkip=1mm, vSkip=1mm);
