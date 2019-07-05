import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

ySizeDef = 5cm;

/*
xangle = "130";
beta = "0.25";
ref = "data_alig-version1_fill_6554_xangle_130_beta_0.25_DS1";
*/
//----------------------------------------------------------------------------------------------------

NewPad(false);
AddToLegend("version = " + version_phys);

AddToLegend("sample = " + sample);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);

AddToLegend("ref = " + replace(ref, "_", "\_"));

AttachLegend();

for (int rpi : rps.keys)
	NewPadLabel(rp_labels[rpi]);

for (int fi : fills_phys_short.keys)
{
	string fill = fills_phys_short[fi];

	write("* " + fill);

	NewRow();
	NewPadLabel(fill);

	for (int rpi : rps.keys)
	{
		NewPad("$x\ung{mm}$", "std.~dev.~of $y\ung{mm}$");
		currentpad.yTicks = RightTicks(0.5, 0.1);

		string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/match.root";
		string p_base = ref + "/" + rps[rpi] + "/method y/c_cmp";
		RootObject obj_base = RootGetObject(f, p_base, error=false);
		if (!obj_base.valid)
			continue;

		draw(RootGetObject(f, p_base + "|h_ref_sel"), "d0,eb", black);
		draw(RootGetObject(f, p_base + "|h_test_bef"), "d0,eb", blue);
		draw(RootGetObject(f, p_base + "|h_test_aft"), "d0,eb", red);

		limits((2, 0), (15, 4.), Crop);
	}
}

GShipout(hSkip=1mm, vSkip=1mm);
