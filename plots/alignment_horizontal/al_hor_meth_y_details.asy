import root;
import pad_layout;

string topDir = "../../data/phys/";

string reference = "data_alig_fill_6228_xangle_150_DS1";

string dataset = "fill_6287/xangle_150/DoubleEG";

string rps[], rp_labels[];
rps.push("L_2_F"); rp_labels.push("L-220-fr");
rps.push("L_1_F"); rp_labels.push("L-210-fr");
rps.push("R_1_F"); rp_labels.push("R-210-fr");
rps.push("R_2_F"); rp_labels.push("R-220-fr");

ySizeDef = 5cm;

//----------------------------------------------------------------------------------------------------

for (int rpi : rps.keys)
	NewPadLabel(rp_labels[rpi]);

NewRow();

for (int rpi : rps.keys)
{
	NewPad("$x\ung{mm}$", "std.~dev.~of $y\ung{mm}$");
	currentpad.yTicks = RightTicks(0.5, 0.1);

	string p_base = reference + "/" + rps[rpi] + "/method y/c_cmp|";
	RootObject h_ref = RootGetObject(topDir + dataset+"/match.root", p_base + "h_ref_sel", error = false);
	if (!h_ref.valid)
		continue;

	draw(h_ref, "d0,eb", black);
	draw(RootGetObject(topDir + dataset+"/match.root", p_base + "h_test_bef"), "d0,eb", blue);
	draw(RootGetObject(topDir + dataset+"/match.root", p_base + "h_test_aft"), "d0,eb", red);

	limits((2, 0), (15, 4), Crop);
}

NewRow();

xTicksDef = LeftTicks(1., 0.2);

for (int rpi : rps.keys)
{
	NewPad("shift$\ung{mm}$", "bins in overlap");
	
	string p_base = reference + "/" + rps[rpi] + "/method y";

	RootObject results = RootGetObject(topDir + dataset+"/match.root", p_base + "/g_results", error = false);
	if (!results.valid)
		continue;

	real ax[] = { 0. };
	real ay[] = { 0. };
	results.vExec("GetPoint", 0, ax, ay); real sh_best = ay[0];
	results.vExec("GetPoint", 1, ax, ay); real sh_best_unc = ay[0];

	draw(RootGetObject(topDir + dataset+"/match.root", p_base + "/g_n_bins"), "p", magenta, mCi+1pt+magenta);

	limits((-5, 0), (+0, 80), Crop);
	yaxis(XEquals(sh_best - sh_best_unc, false), dashed);
	yaxis(XEquals(sh_best, false), solid);
	yaxis(XEquals(sh_best + sh_best_unc, false), dashed);
}

NewRow();

for (int rpi : rps.keys)
{
	NewPad("shift$\ung{mm}$", "$S^2 / N$");
	
	string p_base = reference + "/" + rps[rpi] + "/method y";

	RootObject results = RootGetObject(topDir + dataset+"/match.root", p_base + "/g_results", error = false);
	if (!results.valid)
		continue;

	real ax[] = { 0. };
	real ay[] = { 0. };
	results.vExec("GetPoint", 0, ax, ay); real sh_best = ay[0];
	results.vExec("GetPoint", 1, ax, ay); real sh_best_unc = ay[0];

	draw(RootGetObject(topDir + dataset+"/match.root", p_base + "/g_chi_sq_norm"), "p", heavygreen, mCi+1pt+heavygreen);

	limits((-5, 0), (+0, 200), Crop);
	yaxis(XEquals(sh_best - sh_best_unc, false), dashed);
	yaxis(XEquals(sh_best, false), solid);
	yaxis(XEquals(sh_best + sh_best_unc, false), dashed);
}

GShipout(hSkip=1mm, vSkip=1mm);
