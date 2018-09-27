import root;
import pad_layout;

string topDir = "../../data/phys/";

string datasets[] = {
	"fill_6239/xangle_150/DoubleEG",
	"fill_6268/xangle_150/DoubleEG",
	"fill_6287/xangle_150/DoubleEG",
	"fill_6323/xangle_150/DoubleEG",
	"fill_6371/xangle_150/DoubleEG",
};

string sectors[], s_labels[];
real s_y_mins[], s_y_maxs[];
sectors.push("45"); s_labels.push("sector 45"); s_y_mins.push(38.2); s_y_maxs.push(38.7);
sectors.push("56"); s_labels.push("sector 56"); s_y_mins.push(39.1); s_y_maxs.push(39.6);

ySizeDef = 5cm;

TGraph_errorBar = None;

//----------------------------------------------------------------------------------------------------

NewPad();
for (int si : sectors.keys)
	NewPadLabel(s_labels[si]);

for (int dsi : datasets.keys)
{
	string dataset = datasets[dsi];

	NewRow();
	NewPadLabel(replace(dataset, "_", "\_"));

	for (int si : sectors.keys)
	{
		NewPad("$x_N\ung{mm}$", "$x_F - x_N\ung{mm}$");
		//currentpad.yTicks = RightTicks(0.5, 0.1);

		string f = topDir + dataset+"/x_alignment_relative.root";
		string p_base = "sector " + sectors[si] + "/p_x_diffFN_vs_x_N";

		RootObject hist = RootGetObject(f, p_base, error=false);
		RootObject fit = RootGetObject(f, p_base + "|ff_sl_fix", error=false);

		if (!hist.valid || !fit.valid)
			continue;

		draw(hist, "eb", black);

		TF1_x_min = -inf;
		TF1_x_max = +inf;
		draw(fit, "p,l", red+1pt);

		TF1_x_min = 0;
		TF1_x_max = +inf;
		draw(fit, "p,l", red+dashed);

		//xlimits(0, 15., Crop);
		limits((0, s_y_mins[si]), (15, s_y_maxs[si]), Crop);
	}
}

GShipout(hSkip=1mm, vSkip=1mm);
