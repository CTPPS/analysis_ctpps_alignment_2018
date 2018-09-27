import root;
import pad_layout;

string topDir = "../../data/phys/";

string reference = "data_alig_fill_6228_xangle_150_DS1";

string datasets[] = {
	"fill_6239/xangle_150/DoubleEG",
	"fill_6268/xangle_150/DoubleEG",
	"fill_6287/xangle_150/DoubleEG",
	"fill_6323/xangle_150/DoubleEG",
	"fill_6371/xangle_150/DoubleEG",
};

string rps[], rp_labels[];
rps.push("L_2_F"); rp_labels.push("L-220-fr");
rps.push("L_1_F"); rp_labels.push("L-210-fr");
rps.push("R_1_F"); rp_labels.push("R-210-fr");
rps.push("R_2_F"); rp_labels.push("R-220-fr");

ySizeDef = 5cm;

TGraph_errorBar = None;

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
		NewPad("$x\ung{mm}$", "$S$");
		//currentpad.yTicks = RightTicks(0.5, 0.1);

		string f = topDir + dataset+"/x_alignment_meth_o.root";
		string p_base = reference + "/" + rps[rpi] + "/c_cmp";
		RootObject obj_base = RootGetObject(f, p_base, error=false);

		RootObject results = RootGetObject(f, reference + "/" + rps[rpi] + "/g_results", error=false);

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
		limits((0, 0.05), (15, 0.2), Crop);
	}
}

GShipout(hSkip=1mm, vSkip=1mm);
