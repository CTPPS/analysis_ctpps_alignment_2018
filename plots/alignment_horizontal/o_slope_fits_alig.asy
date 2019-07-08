import root;
import pad_layout;

string topDir = "../../";

include "../common.asy";

//fill = "6554";
fill = "7206";

xangle = "130";
beta = "0.25";
string ref = "data_alig-version1_fill_6554_xangle_130_beta_0.25_DS1";

sample = "DS1";

string f = topDir + "data/" + version_alig + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/x_alignment_meth_o.root";

//xTicksDef = LeftTicks(2., 1.);

//----------------------------------------------------------------------------------------------------

int n_slices = 7;

string[] GenerateSlices(real x_min)
{
	real steps[] = {0, 1, 2, 4, 6, 8, 10};

	string result[];
	for (real s : steps)
		result.push(format("%#.1f", x_min + s) + "-" + format("%#.1f", x_min + s + 0.2));

	return result;
}

string[] GetXSlices(string rp)
{

	if (rp == "L_2_F") return GenerateSlices(2.0);
	if (rp == "L_1_F") return GenerateSlices(2.0);
	if (rp == "R_1_F") return GenerateSlices(3.0);
	if (rp == "R_2_F") return GenerateSlices(2.5);

	return new string[] {};
}

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_alig);
AddToLegend("fill = " + fill);
AddToLegend("xangle = " + xangle);
AddToLegend("beta = " + beta);
AddToLegend("sample = " + sample);

AttachLegend();

for (int rpi : rps.keys)
	NewPadLabel(rp_labels[rpi]);

for (int xsi = 0; xsi < n_slices; ++xsi)
{
	NewRow();

	NewPadLabel(format("x slice %u", xsi));

	for (int rpi : rps.keys)
	{
		NewPad("$y\ung{mm}$");
		scale(Linear, Linear(true));

		string x_slices[] = GetXSlices(rps[rpi]);
		if (x_slices.length <= xsi)
			continue;
		string x_slice = x_slices[xsi];

		string ob = ref + "/" + rps[rpi] + "/fits_test/" + x_slice;

		RootObject hist = RootGetObject(f, ob + "", error=true);	
		RootObject fit = RootGetObject(f, ob + "|ff_pol1", error=true);	

		if (!hist.valid)
			continue;

		draw(hist, "d0,eb", blue);
		draw(fit, "l", red+1pt);

		AddToLegend("x = " + x_slice);

		limits((-6., -2), (+10, +1.5), Crop);

		AttachLegend(S, N);
	}
}

GShipout(vSkip=0mm);
