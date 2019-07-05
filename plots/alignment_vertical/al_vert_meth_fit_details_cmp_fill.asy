import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

xSizeDef = 9cm;

xTicksDef = LeftTicks(1., 0.5);
yTicksDef = RightTicks(0.5, 0.1);

TGraph_errorBar = None;

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_phys);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);
AddToLegend("sample = " + sample);

AttachLegend();

for (int rpi : rps.keys)
	NewPadLabel(rp_labels[rpi]);

//----------------------------------------------------------------------------------------------------

for (int fi : fills_phys_short.keys)
{
	string fill = fills_phys_short[fi];
	
	NewRow();

	NewPadLabel(fill);

	for (int rpi : rps.keys)
	{
		NewPad("$x\ung{mm}$", "mean of $y\ung{mm}$");

		string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/y_alignment.root";
	
		RootObject graph = RootGetObject(f, rps[rpi] + "/g_y_cen_vs_x", error=true);
		RootObject fit = RootGetObject(f, rps[rpi] + "/g_y_cen_vs_x|ff", error=false);
		RootObject results = RootGetObject(f, rps[rpi] + "/g_results", error=false);

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

		TF1_x_min = -inf;
		TF1_x_max = +inf;
		draw(fit, "def", blue+2pt);

		TF1_x_min = x_min;
		TF1_x_max = x_max;
		draw(fit, "def", blue+dashed);

		draw(graph, "p", red);

		draw((-sh_x, b), mCi+3pt+magenta);
	
		limits((x_min, y_cen - 2.0), (x_max, y_cen + 2.0), Crop);

		yaxis(XEquals(-sh_x, false), heavygreen);
	
		AttachLegend(BuildLegend(rp_labels[rpi], N), N);
	}
}
