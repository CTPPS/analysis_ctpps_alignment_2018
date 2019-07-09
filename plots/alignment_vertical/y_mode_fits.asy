import root;
import pad_layout;

string topDir = "../../";

include "../common.asy";

//fill = "7048";

string f = topDir + "data/phys-version1/fill_" + fill + "/xangle_" + xangle + "_beta_" + beta + "/" + sample + "/y_alignment.root";


xTicksDef = LeftTicks(2., 1.);

//----------------------------------------------------------------------------------------------------

int n_slices = 6;

string[] GetXSlices(string rp)
{
	if (rp == "L_2_F") return new string[] { "45.053", "46.049", "47.045", "48.042", "49.038", "50.034" };
	if (rp == "L_1_F") return new string[] { "7.045", "8.042", "9.038", "10.034", "11.031", "12.027" };
	if (rp == "R_1_F") return new string[] { "6.049", "7.045", "8.042", "9.038", "10.034", "11.031" };
	if (rp == "R_2_F") return new string[] { "45.053", "46.049", "47.045", "48.042", "49.038", "50.034" };

	return new string[] {};
}

//----------------------------------------------------------------------------------------------------

NewPad(false);

AddToLegend("version = " + version_phys);
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

		string x_slice = GetXSlices(rps[rpi])[xsi];

		string d = rps[rpi] + "/x=" + x_slice;

		RootObject hist = RootGetObject(f, d + "/h_y", error=true);	
		RootObject fit = RootGetObject(f, d + "/h_y|ff_fit", error=false);	
		RootObject data = RootGetObject(f, d + "/g_data", error=false);

		if (!hist.valid)
			continue;

		draw(hist, "vl", blue);
		draw(fit, "l", red+1pt);

		if (data.valid)
		{
			real ax[] = {0};
			real ay[] = {0};

			data.vExec("GetPoint", 0, ax, ay); real y_mode = ax[0], y_mode_unc = ay[0];
			data.vExec("GetPoint", 1, ax, ay); real chiSq = ax[0], ndf = ay[0];
			data.vExec("GetPoint", 2, ax, ay); bool valid = (ax[0] > 0);

			if (valid)
			{
				yaxis(XEquals(y_mode - y_mode_unc, false), heavygreen+dashed);
				yaxis(XEquals(y_mode, false), heavygreen+2pt);
				yaxis(XEquals(y_mode + y_mode_unc, false), heavygreen+dashed);
			}

			AddToLegend("x = " + x_slice);
			//AddToLegend(format("$\ch^2/ndf = %.1f$", chiSq/ndf));
			//AddToLegend(format("$unc = %.1f$", y_mode_unc));
		}

		xlimits(-2., +11., Crop);

		AttachLegend(S, N);
	}
}

GShipout(vSkip=0mm);
