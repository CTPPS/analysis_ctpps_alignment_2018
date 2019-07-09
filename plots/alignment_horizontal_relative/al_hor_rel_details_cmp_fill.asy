import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

ySizeDef = 5cm;

TGraph_errorBar = None;

yTicksDef = RightTicks(0.5, 0.1);

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_phys);
AddToLegend("sample = " + sample);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);

AttachLegend();

for (int ai : a_sectors.keys)
	NewPadLabel(a_labels[ai]);

for (int fi : fills_phys_short.keys)
{
	string fill = fills_phys_short[fi];

	NewRow();
	NewPadLabel(fill);

	for (int ai : a_sectors.keys)
	{
		NewPad("$x_N\ung{mm}$", "$x_F - x_N\ung{mm}$");
		//currentpad.yTicks = RightTicks(0.5, 0.1);

		string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/x_alignment_relative.root";
		string p_base = a_sectors[ai] + "/p_x_diffFN_vs_x_N";

		RootObject hist = RootGetObject(f, p_base, error=false);
		RootObject fit = RootGetObject(f, p_base + "|ff_sl_fix", error=false);
		RootObject results = RootGetObject(f, a_sectors[ai] + "/g_results", error=false);

		if (!hist.valid || !fit.valid || !results.valid)
			continue;

		real ax[] = {0.};
		real ay[] = {0.};
		results.vExec("GetPoint", 0, ax, ay); real sh_x = ax[0];
		results.vExec("GetPoint", 1, ax, ay); real a = ax[0], a_unc = ay[0];
		results.vExec("GetPoint", 2, ax, ay); real b = ax[0], b_unc = ay[0];
		results.vExec("GetPoint", 3, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

		TF1_x_min = -inf;
		TF1_x_max = +inf;
		draw(fit, "p,l", blue+1.5pt);

		TF1_x_min = 0;
		TF1_x_max = +inf;
		draw(fit, "p,l", blue+dashed);

		draw(hist, "eb", red);

		draw((-sh_x, b), mCi+3pt+magenta);

		real y_min = 37.5, y_max = 40;
		if (a_sectors[ai] == "sector 45") { y_min = 37.5; y_max = 38.5; }
		if (a_sectors[ai] == "sector 56") { y_min = 38.7; y_max = 39.7; }

		limits((0, y_min), (15, y_max), Crop);

		yaxis(XEquals(-sh_x, false), heavygreen);
	}
}

GShipout(hSkip=1mm, vSkip=1mm);
