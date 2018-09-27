import root;
import pad_layout;

string topDir = "../../data/phys/";

string plots[], p_arms[], p_rps[], p_x_axis[], p_y_axis[];
plots.push("sector 45/N/p_y_diffFN_vs_y"); p_arms.push("sector 45"); p_rps.push("near"); p_x_axis.push("y_{LN}\ung{mm}"); p_y_axis.push("y_{LF} - y_{LN}\ung{mm}");
plots.push("sector 45/F/p_y_diffFN_vs_y"); p_arms.push("sector 45"); p_rps.push("far"); p_x_axis.push("y_{LF}\ung{mm}"); p_y_axis.push("y_{LF} - y_{LN}\ung{mm}");
plots.push("sector 56/N/p_y_diffFN_vs_y"); p_arms.push("sector 56"); p_rps.push("near"); p_x_axis.push("y_{RN}\ung{mm}"); p_y_axis.push("y_{RF} - y_{RN}\ung{mm}");
plots.push("sector 56/F/p_y_diffFN_vs_y"); p_arms.push("sector 56"); p_rps.push("far"); p_x_axis.push("y_{RF}\ung{mm}"); p_y_axis.push("y_{RF} - y_{RN}\ung{mm}");

xSizeDef = 9cm;

xTicksDef = LeftTicks(1., 0.5);
yTicksDef = RightTicks(0.1, 0.05);

string datasets[] = {
	"fill_6239/xangle_150/DoubleEG",
	"fill_6268/xangle_150/DoubleEG",
	"fill_6287/xangle_150/DoubleEG",
	"fill_6323/xangle_150/DoubleEG",
	"fill_6371/xangle_150/DoubleEG",
};

// TODO
/*
string datasets[] = {
	"fill_6263/xangle_150/DoubleEG",
	"fill_6266/xangle_150/DoubleEG",
};
*/

//----------------------------------------------------------------------------------------------------

NewPad(false);
for (int pli : plots.keys)
	NewPadLabel(p_arms[pli] + ", " + p_rps[pli]);


for (int dsi : datasets.keys)
{
	string dataset = datasets[dsi];
	
	NewRow();

	NewPadLabel(replace(dataset, "_", "\_"));

	for (int pli : plots.keys)
	{
		NewPad("$" + p_x_axis[pli] + "$", "mean of $" + p_y_axis[pli] + "$");
	
		RootObject profile = RootGetObject(topDir + dataset + "/y_alignment_alt.root", plots[pli], error=false);
		RootObject fit = RootGetObject(topDir + dataset + "/y_alignment_alt.root", plots[pli] + "|ff", error=false);

		if (!fit.valid)
			continue;

		draw(profile, "eb,d0", red);

		TF1_x_min = -inf;
		TF1_x_max = +inf;
		draw(fit, "def", blue+1pt);

		real p0 = fit.rExec("GetParameter", 0);
		real p3 = fit.rExec("GetParameter", 3);

		real y_cen = p0;

		draw((p3, p0), mCi+3pt+heavygreen);

		limits((-1, y_cen - 0.5), (+9, y_cen + 0.5), Crop);

		//AttachLegend();
	}
}

GShipout(hSkip=0mm, vSkip=0mm);
