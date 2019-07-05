import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

ySizeDef = 5cm;

TGraph_errorBar = None;

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
		NewPad("$x\ung{mm}$", "$S$");
		//currentpad.yTicks = RightTicks(0.5, 0.1);

		string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/x_alignment_meth_o.root";
		string p_base = ref + "/" + rps[rpi] + "/c_cmp";
		RootObject obj_base = RootGetObject(f, p_base, error=false);

		RootObject results = RootGetObject(f, ref + "/" + rps[rpi] + "/g_results", error=false);

		if (!obj_base.valid || !results.valid)
			continue;

		real ax[] = {0.};
		real ay[] = {0.};
		results.vExec("GetPoint", 0, ax, ay); real bsh = ax[0], bsh_unc = ay[0];
		results.vExec("GetPoint", 1, ax, ay); real x_min_ref = ax[0], x_max_ref = ay[0];
		results.vExec("GetPoint", 2, ax, ay); real x_min_test = ax[0], x_max_test = ay[0];

		TGraph_x_min = -inf; TGraph_x_max = +inf;
		draw(RootGetObject(f, p_base + "#0"), "l", black+opacity(0.5)+dashed);
		TGraph_x_min = x_min_ref; TGraph_x_max = x_max_ref;
		draw(RootGetObject(f, p_base + "#0"), "p,l", black);

		TGraph_x_min = -inf; TGraph_x_max = +inf;
		draw(RootGetObject(f, p_base + "#1"), "l", blue+opacity(0.5)+dashed);	
		TGraph_x_min = x_min_test; TGraph_x_max = x_max_test;
		draw(RootGetObject(f, p_base + "#1"), "p,l", blue);

		TGraph_x_min = -inf; TGraph_x_max = +inf;
		draw(RootGetObject(f, p_base + "#2"), "l", red+opacity(0.5)+dashed);
		TGraph_x_min = x_min_test + bsh; TGraph_x_max = x_max_test + bsh;
		draw(RootGetObject(f, p_base + "#2"), "p,l", red);

		//xlimits(0, 15., Crop);
		limits((0, 0.03), (18, 0.15), Crop);
	}
}

GShipout(hSkip=1mm, vSkip=1mm);
