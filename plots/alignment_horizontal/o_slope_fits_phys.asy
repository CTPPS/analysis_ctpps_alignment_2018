import root;
import pad_layout;

string topDir = "../../";

include "../common.asy";

//fill = "6639";
//fill = "6774";
//fill = "7139";
fill = "7334";

xangle = "130";
beta = "0.25";
string ref = "data_alig-version1_fill_6554_xangle_130_beta_0.25_DS1";

string f = topDir + "data/" + version_phys + "/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/x_alignment_meth_o.root";

//xTicksDef = LeftTicks(2., 1.);

//----------------------------------------------------------------------------------------------------

int n_slices = 7;

string[] GetXSlices(string rp)
{
	if (rp == "L_2_F") return new string[] { "46.0-46.2", "47.0-47.2", "48.0-48.2", "50.0-50.2", "52.0-52.2", "54.0-54.2", "56.0-56.2" };
	if (rp == "L_1_F") return new string[] { "7.0-7.2", "8.0-8.2", "9.0-9.2", "11.0-11.2", "13.0-13.2", "15.0-15.2", "17.0-17.2" };
	if (rp == "R_1_F") return new string[] { "6.0-6.2", "7.0-7.2", "8.0-8.2", "10.0-10.2", "12.0-12.2", "14.0-14.2", "16.0-16.2" };
	if (rp == "R_2_F") return new string[] { "45.0-45.2", "46.0-46.2", "47.0-47.2", "49.0-49.2", "51.0-51.2", "53.0-53.2", "55.0-55.2" };

	return new string[] {};
}

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_phys);
AddToLegend("ref = " + replace(ref, "_", "\_"));
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
