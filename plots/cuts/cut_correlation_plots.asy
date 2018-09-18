import root;
import pad_layout;

string topDir = "../../";

string sectors[];
sectors.push("sector 45");
sectors.push("sector 56");

string cuts[], c_labels[], c_x_labels[], c_y_labels[];
real c_ranges[];
cuts.push("cut_h"); c_labels.push("cut h"); c_ranges.push(0.4); c_x_labels.push("$x(\hbox{210-fr})\ung{mm}$"); c_y_labels.push("$x(\hbox{220-fr})\ung{mm}$");
cuts.push("cut_v"); c_labels.push("cut v"); c_ranges.push(0.2); c_x_labels.push("$y(\hbox{210-fr})\ung{mm}$"); c_y_labels.push("$y(\hbox{220-fr})\ung{mm}$");

string datasets[] = {
//	"data/alig/fill_5685/xangle_120/DS1",

/*
	"data/phys/fill_6348/xangle_150/SingleMuon",
	"data/phys/fill_6349/xangle_150/SingleMuon",
	"data/phys/fill_6355/xangle_150/SingleMuon",
	"data/phys/fill_6356/xangle_150/SingleMuon",
*/

	"data/phys/fill_6288/xangle_150/SingleMuon",
	"data/phys/fill_6307/xangle_150/SingleMuon",
	"data/phys/fill_6360/xangle_150/SingleMuon",
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

	string f = topDir + datasets[dsi] + "/distributions.root";

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

			string f = topDir + datasets[dsi] + "/distributions.root";
			string obj_path_base = sectors[sci] + "/cuts/" + cuts[cti] + "/canvas_before";

			RootObject hist = RootGetObject(f, obj_path_base + "#0");
			hist.vExec("Rebin2D", 3, 3);
			draw(hist, "def");

			draw(RootGetObject(f, obj_path_base + "#1"), "l", black);
			draw(RootGetObject(f, obj_path_base + "#2"), "l", black);

			//xlimits(-r, r, Crop);

			//AttachLegend(format("%u", fill), NW, NW);
		}
	}

}
