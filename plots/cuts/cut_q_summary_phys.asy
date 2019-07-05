import root;
import pad_layout;

include "../common.asy";

string topDir = "../../";

string cuts[], c_labels[];
real c_mins[], c_maxs[], c_Ticks[], c_ticks[];
cuts.push("cut_h"); c_labels.push("cut h"); c_mins.push(-0.9); c_maxs.push(+0.9); c_Ticks.push(0.20); c_ticks.push(0.1);
cuts.push("cut_v"); c_labels.push("cut v"); c_mins.push(-0.7); c_maxs.push(+0.7); c_Ticks.push(0.2); c_ticks.push(0.1);

xSizeDef = 8cm;

//----------------------------------------------------------------------------------------------------

real GetCutThreshold(string cut, string sector)
{
	real n_si = 4.;

	if (cut == "cut_h" && sector == "sector 45") return n_si * 0.2;
	if (cut == "cut_v" && sector == "sector 45") return n_si * 0.15;

	if (cut == "cut_h" && sector == "sector 56") return n_si * 0.2;
	if (cut == "cut_v" && sector == "sector 56") return n_si * 0.15;

	return 0;
}

//----------------------------------------------------------------------------------------------------

NewPad(false);
AddToLegend("version = " + version_phys);
AddToLegend("sample = " + sample);

for (int cfgi : cfg_xangles.keys)
	AddToLegend("xangle " + cfg_xangles[cfgi] + ", beta " + cfg_betas[cfgi], cfg_pens[cfgi]);

AttachLegend();


for (int ai : arms.keys)
{
	for (int cti : cuts.keys)
	{
		NewPad(false);
		label("\vbox{\SetFontSizesXX\hbox{"+a_sectors[ai]+"}\hbox{"+c_labels[cti]+"}}");
	}
}

for (int fi : fills_phys_short.keys)
{
	string fill = fills_phys_short[fi];

	NewRow();

	NewPadLabel(fill);
	
	for (int ai : arms.keys)
	{
		for (int cti : cuts.keys)
		{
			NewPad();
			currentpad.xTicks = LeftTicks(c_Ticks[cti], c_ticks[cti]);
			
			real x_min = c_mins[cti];
			real x_max = c_maxs[cti];

			TH1_x_min = x_min;
			TH1_x_max = x_max;

			for (int cfgi : cfg_xangles.keys)
			{
				string xangle = cfg_xangles[cfgi];
				string beta = cfg_betas[cfgi];

				string dir_base = "fill_" + fill + "/xangle_" + xangle + "_beta_" + beta;
				string f = topDir + "data/" + version_phys + "/" + dir_base + "/" + sample + "/distributions.root";
				string obj_path = a_sectors[ai] + "/cuts/" + cuts[cti] + "/h_q_" + cuts[cti] + "_aft";

				pen p = cfg_pens[cfgi];

				RootObject obj = RootGetObject(f, obj_path, error=false);
				if (obj.valid)
					draw(obj, "d0,vl,N", p);	
			}

			xlimits(x_min, x_max, Crop);

			real th = GetCutThreshold(cuts[cti], a_sectors[ai]);

			yaxis(XEquals(-th, false), dashed);
			yaxis(XEquals(+th, false), dashed);
		}
	}
}
