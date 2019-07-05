import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

string plots[], p_arms[], p_rps[], p_x_axis[], p_y_axis[];
plots.push("sector 45/N/p_y_diffFN_vs_y"); p_arms.push("sector 45"); p_rps.push("near"); p_x_axis.push("y_{LN}\ung{mm}"); p_y_axis.push("y_{LF} - y_{LN}\ung{mm}");
plots.push("sector 45/F/p_y_diffFN_vs_y"); p_arms.push("sector 45"); p_rps.push("far"); p_x_axis.push("y_{LF}\ung{mm}"); p_y_axis.push("y_{LF} - y_{LN}\ung{mm}");
plots.push("sector 56/N/p_y_diffFN_vs_y"); p_arms.push("sector 56"); p_rps.push("near"); p_x_axis.push("y_{RN}\ung{mm}"); p_y_axis.push("y_{RF} - y_{RN}\ung{mm}");
plots.push("sector 56/F/p_y_diffFN_vs_y"); p_arms.push("sector 56"); p_rps.push("far"); p_x_axis.push("y_{RF}\ung{mm}"); p_y_axis.push("y_{RF} - y_{RN}\ung{mm}");

xSizeDef = 9cm;

xTicksDef = LeftTicks(1., 0.5);
yTicksDef = RightTicks(0.1, 0.05);

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_phys);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);
AddToLegend("sample = " + sample);

AttachLegend();

for (int pli : plots.keys)
	NewPadLabel(p_arms[pli] + ", " + p_rps[pli]);

for (int fi : fills_phys_short.keys)
{
	string fill = fills_phys_short[fi];
	
	NewRow();

	NewPadLabel(fill);

	for (int pli : plots.keys)
	{
		NewPad("$" + p_x_axis[pli] + "$", "mean of $" + p_y_axis[pli] + "$");

		string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/y_alignment_alt.root";
	
		RootObject profile = RootGetObject(f, plots[pli], error=false);
		RootObject fit = RootGetObject(f, plots[pli] + "|ff", error=false);

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
