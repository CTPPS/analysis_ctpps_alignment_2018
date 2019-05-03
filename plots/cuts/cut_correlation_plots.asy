import root;
import pad_layout;

string topDir = "../../";

string sectors[];
sectors.push("sector 45");
sectors.push("sector 56");

string cuts[], c_labels[], c_x_labels[], c_y_labels[];
real c_ranges[];
cuts.push("cut_h"); c_labels.push("cut h"); c_ranges.push(0.4); c_x_labels.push("$x(\hbox{210-fr})\ung{mm}$"); c_y_labels.push("$x(\hbox{220-fr})\ung{mm}$");
//cuts.push("cut_v"); c_labels.push("cut v"); c_ranges.push(0.2); c_x_labels.push("$y(\hbox{210-fr})\ung{mm}$"); c_y_labels.push("$y(\hbox{220-fr})\ung{mm}$");

string datasets[] = {
	"fill_6583/xangle_ALL_beta_ALL/ZeroBias",
	"fill_6719/xangle_ALL_beta_ALL/EGamma",
	"fill_6860/xangle_ALL_beta_ALL/ZeroBias",
	"fill_7005/xangle_ALL_beta_ALL/ZeroBias",
	"fill_7145/xangle_ALL_beta_ALL/ZeroBias",
	"fill_7334/xangle_ALL_beta_ALL/ZeroBias",
};

TH2_palette = Gradient(blue, heavygreen, yellow, red);

//----------------------------------------------------------------------------------------------------

NewPad(false);

for (int sci : sectors.keys)
{
	for (int cti : cuts.keys)
	{
		NewPad(false);
		label("\vbox{\SetFontSizesXX\hbox{"+sectors[sci]+"}\hbox{"+c_labels[cti]+"}}");
	}
}

for (int dsi : datasets.keys)
{
	NewRow();

	NewPad(false);
	label("{\SetFontSizesXX " + replace(datasets[dsi], "_", "\_") + "}");

	string f = topDir + "data/phys/" + datasets[dsi] + "/distributions.root";

	for (int sci : sectors.keys)
	{
		for (int cti : cuts.keys)
		{
			NewPad(c_x_labels[cti], c_y_labels[cti]);
			scale(Linear, Linear, Log);
			//currentpad.xTicks = LeftTicks(c_Ticks[cti], c_ticks[cti]);
			
			//real r = c_ranges[cti];

			//TH1_x_min = -r;
			//TH1_x_max = +r;

			string obj_path_base = sectors[sci] + "/cuts/" + cuts[cti] + "/canvas_before";

			RootObject hist = RootGetObject(f, obj_path_base + "#0");
			hist.vExec("Rebin2D", 3, 3);
			draw(hist, "def");

			draw(RootGetObject(f, obj_path_base + "#1"), "l", black);
			draw(RootGetObject(f, obj_path_base + "#2"), "l", black);

			//xlimits(-r, r, Crop);

			if (cuts[cti] == "cut_h")
				limits((0, 40), (30, 70), Crop);

			//AttachLegend(format("%u", fill), NW, NW);
		}
	}

}
