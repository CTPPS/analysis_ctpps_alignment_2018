import root;
import pad_layout;

string topDir = "../../";

string dirBase = "data/phys-version1/";

//string dir = "fill_6639/xangle_160_beta_0.30/ALL/";
//string dir = "fill_6854/xangle_160_beta_0.30/ALL/";
string dir = "fill_7048/xangle_160_beta_0.30/ALL/";
//string dir = "fill_7334/xangle_160_beta_0.30/ALL/";

string f = topDir + dirBase + dir + "y_alignment.root";

string x_slices_[] = {
	"3.200",
};

string rps[], rp_labels[], rp_arms[], x_slices[][];
rps.push("L_2_F"); rp_labels.push("45-220-fr"); rp_arms.push("arm0"); x_slices.push(new string[] { "45.053", "46.049", "47.045", "48.042", "49.038", "50.034" });
rps.push("L_1_F"); rp_labels.push("45-210-fr"); rp_arms.push("arm0"); x_slices.push(new string[] { "7.045", "8.042", "9.038", "10.034", "11.031", "12.027" });
rps.push("R_1_F"); rp_labels.push("56-210-fr"); rp_arms.push("arm1"); x_slices.push(new string[] { "6.049", "7.045", "8.042", "9.038", "10.034", "11.031" });
rps.push("R_2_F"); rp_labels.push("56-220-fr"); rp_arms.push("arm1"); x_slices.push(new string[] { "45.053", "46.049", "47.045", "48.042", "49.038", "50.034" });


xTicksDef = LeftTicks(2., 1.);

//----------------------------------------------------------------------------------------------------

NewPadLabel(replace(dir, "_", "\_"));
for (int rpi : rps.keys)
	NewPadLabel(rp_labels[rpi]);

for (int xsi : x_slices[0].keys)
{
	NewRow();

	NewPadLabel("");

	for (int rpi : rps.keys)
	{
		NewPad("$y\ung{mm}$");
		scale(Linear, Linear(true));

		string d = rps[rpi] + "/x=" + x_slices[rpi][xsi];

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

			AddToLegend("x = " + x_slices[rpi][xsi]);
			//AddToLegend(format("$\ch^2/ndf = %.1f$", chiSq/ndf));
			//AddToLegend(format("$unc = %.1f$", y_mode_unc));
		}

		xlimits(-2., +11., Crop);

		AttachLegend(S, N);
	}
}

GShipout(vSkip=0mm);
