import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

string cuts[], c_labels[], c_x_labels[], c_y_labels[];
real c_ranges[];
cuts.push("cut_h"); c_labels.push("cut h"); c_ranges.push(0.4); c_x_labels.push("$x(\hbox{210-fr})\ung{mm}$"); c_y_labels.push("$x(\hbox{220-fr})\ung{mm}$");
cuts.push("cut_v"); c_labels.push("cut v"); c_ranges.push(0.2); c_x_labels.push("$y(\hbox{210-fr})\ung{mm}$"); c_y_labels.push("$y(\hbox{220-fr})\ung{mm}$");

TH2_palette = Gradient(blue, heavygreen, yellow, red);

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_phys);
AddToLegend("sample = " + sample);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);

AttachLegend();

for (int ai : a_sectors.keys)
{
	for (int cti : cuts.keys)
		NewPadLabel("\vbox{\hbox{"+a_sectors[ai]+"}\hbox{"+c_labels[cti]+"}}");
}

for (int fi : fills_phys_short.keys)
{
	string fill = fills_phys_short[fi];

	NewRow();

	NewPadLabel(fill);

	string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/distributions.root";

	for (int ai : a_sectors.keys)
	{
		for (int cti : cuts.keys)
		{
			NewPad(c_x_labels[cti], c_y_labels[cti]);
			scale(Linear, Linear, Log);
			//currentpad.xTicks = LeftTicks(c_Ticks[cti], c_ticks[cti]);
			
			//real r = c_ranges[cti];

			//TH1_x_min = -r;
			//TH1_x_max = +r;

			string obj_path_base = a_sectors[ai] + "/cuts/" + cuts[cti] + "/canvas_before";

			RootObject hist = RootGetObject(f, obj_path_base + "#0");
			hist.vExec("Rebin2D", 3, 3);
			draw(hist, "def");

			draw(RootGetObject(f, obj_path_base + "#1"), "l", black);
			draw(RootGetObject(f, obj_path_base + "#2"), "l", black);

			//xlimits(-r, r, Crop);

			if (cuts[cti] == "cut_h")
				limits((0, 40), (30, 70), Crop);
			else
				limits((-10, -10), (+10, +10), Crop);

			//AttachLegend(format("%u", fill), NW, NW);
		}
	}
}

GShipout(vSkip=1mm);
