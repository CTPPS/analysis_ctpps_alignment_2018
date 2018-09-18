import root;
import pad_layout;

include "../fills_samples.asy";
InitDataSets();
//AddDataSet("fill_6371/xangle_130");

string topDir = "../../";

string sectors[];
sectors.push("sector 45");
sectors.push("sector 56");

string cuts[], c_labels[];
real c_mins[], c_maxs[], c_Ticks[], c_ticks[];
cuts.push("cut_h"); c_labels.push("cut h"); c_mins.push(-0.5); c_maxs.push(+0.5); c_Ticks.push(0.20); c_ticks.push(0.1);

cuts.push("cut_v"); c_labels.push("cut v"); c_mins.push(-0.5); c_maxs.push(+0.5); c_Ticks.push(0.2); c_ticks.push(0.1);
//cuts.push("cut_v"); c_labels.push("cut v"); c_mins.push(-0.5); c_maxs.push(+0.5); c_Ticks.push(0.2); c_ticks.push(0.1);
//cuts.push("cut_v"); c_labels.push("cut v"); c_mins.push(0.5); c_maxs.push(1.5); c_Ticks.push(0.2); c_ticks.push(0.1);

string dataset = "ZeroBias";

xSizeDef = 8cm;

//----------------------------------------------------------------------------------------------------

pen XangleBetaColor(int xangle, real beta)
{
	if (xangle == 160 && beta == 0.30) return red;
	if (xangle == 130 && beta == 0.30) return blue;
	if (xangle == 130 && beta == 0.27) return magenta;
	if (xangle == 130 && beta == 0.25) return heavygreen;

	return black;
}

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

for (int fi : fill_data.keys)
{
	int fill = fill_data[fi].fill;
	
	if (fill < 6500 || fill > 6800)
	//if (fill < 6800 || fill > 7000)
	//if (fill < 7000 || fill > 7200)
		continue;
	
	NewRow();

	NewPad(false);
	label("\vbox{\SetFontSizesXX \hbox{"+format("%u", fill)+"}}");
	
	for (int sci : sectors.keys)
	{
		for (int cti : cuts.keys)
		{
			NewPad();
			currentpad.xTicks = LeftTicks(c_Ticks[cti], c_ticks[cti]);
			
			real x_min = c_mins[cti];
			real x_max = c_maxs[cti];

			TH1_x_min = x_min;
			TH1_x_max = x_max;

			for (int dsi : fill_data[fi].datasets.keys)
			{
				string dir_base = fill_data[fi].datasets[dsi].tag;
				int xangle = fill_data[fi].datasets[dsi].xangle;
				real beta = fill_data[fi].datasets[dsi].beta;

				if (xangle != 160 || beta != 0.30)
					continue;

				string f = topDir + "data/phys/" + dir_base + "/" + dataset + "/distributions.root";
				string obj_path = sectors[sci] + "/cuts/" + cuts[cti] + "/h_q_" + cuts[cti] + "_aft";

				pen p = XangleBetaColor(xangle, beta);

				RootObject obj = RootGetObject(f, obj_path, error=false);
				if (obj.valid)
					draw(obj, "d0,vl,N", p);	
			}

			xlimits(x_min, x_max, Crop);

			AttachLegend(format("%u", fill), NW, NW);
		}
	}

	if (fi == 0)
	{
		NewPad(false);
		AddToLegend(format("xangle = %u", 160) + format(", $\be^* = %.2f$", 0.30), XangleBetaColor(160, 0.30));
		AddToLegend(format("xangle = %u", 130) + format(", $\be^* = %.2f$", 0.30), XangleBetaColor(130, 0.30));
		AddToLegend(format("xangle = %u", 130) + format(", $\be^* = %.2f$", 0.27), XangleBetaColor(130, 0.27));
		AddToLegend(format("xangle = %u", 130) + format(", $\be^* = %.2f$", 0.25), XangleBetaColor(130, 0.25));
		AttachLegend();
	}
}
