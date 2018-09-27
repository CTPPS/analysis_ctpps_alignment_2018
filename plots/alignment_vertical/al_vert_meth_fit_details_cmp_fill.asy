import root;
import pad_layout;

string topDir = "../../data/phys/";

int rp_ids[];
string rps[], rp_labels[];
rp_ids.push(23); rps.push("L_2_F"); rp_labels.push("L-220-fr");
rp_ids.push(3); rps.push("L_1_F"); rp_labels.push("L-210-fr");
rp_ids.push(103); rps.push("R_1_F"); rp_labels.push("R-210-fr");
rp_ids.push(123); rps.push("R_2_F"); rp_labels.push("R-220-fr");

xSizeDef = 9cm;

xTicksDef = LeftTicks(1., 0.5);
yTicksDef = RightTicks(0.2, 0.1);

string datasets[] = {
	"fill_6239/xangle_150/DoubleEG",
	"fill_6268/xangle_150/DoubleEG",
	"fill_6287/xangle_150/DoubleEG",
	"fill_6323/xangle_150/DoubleEG",
	"fill_6371/xangle_150/DoubleEG",
};

//----------------------------------------------------------------------------------------------------

for (int dsi : datasets.keys)
{
	string dataset = datasets[dsi];
	
	NewRow();

	NewPadLabel(replace(dataset, "_", "\_"));


	for (int rpi : rps.keys)
	{
		NewPad("$x\ung{mm}$", "mean of $y\ung{mm}$");
	
		RootObject profile = RootGetObject(topDir + dataset + "/y_alignment.root", rps[rpi] + "/p_y_vs_x");
		RootObject fit = RootGetObject(topDir + dataset + "/y_alignment.root", rps[rpi] + "/p_y_vs_x|ff", error=false);
		RootObject results = RootGetObject(topDir + dataset + "/y_alignment.root", rps[rpi] + "/g_results");

		if (!fit.valid)
			continue;

		real ax[] = {0.};
		real ay[] = {0.};
		results.vExec("GetPoint", 0, ax, ay); real sh_x = ax[0];
		results.vExec("GetPoint", 1, ax, ay); real a = ax[0], a_unc = ay[0];
		results.vExec("GetPoint", 2, ax, ay); real b = ax[0], b_unc = ay[0];
		results.vExec("GetPoint", 3, ax, ay); real b_fs = ax[0], b_fs_unc = ay[0];

		real x_min = -sh_x - 1;
		real x_max = -sh_x + 8;
		real y_cen = fit.rExec("Eval", -sh_x + 3);

		draw(profile, "eb,d0", red);

		TF1_x_min = -inf;
		TF1_x_max = +inf;
		draw(fit, "def", blue+2pt);

		TF1_x_min = x_min;
		TF1_x_max = x_max;
		draw(fit, "def", blue+dashed);

		draw((-sh_x, b), mCi+3pt+magenta);
	
		limits((x_min, y_cen - 0.7), (x_max, y_cen + 0.5), Crop);

		yaxis(XEquals(-sh_x, false), heavygreen);
	
		AttachLegend(rp_labels[rpi]);
	}
}
