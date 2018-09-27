string reference_std = "data_alig_fill_6554_xangle_160_beta_0.30_DS1";
string datasets_std[] = {
	"fill_6583/xangle_160_beta_0.30/ZeroBias",
	"fill_6719/xangle_160_beta_0.30/ZeroBias",
	"fill_6860/xangle_160_beta_0.30/ZeroBias",
	"fill_7005/xangle_160_beta_0.30/ZeroBias",
	"fill_7145/xangle_160_beta_0.30/ZeroBias",
};

//----------------------------------------------------------------------------------------------------

real GetMeanHorizontalAlignment(string rp)
{
	if (rp == "L_2_F") return -42.0;
	if (rp == "L_1_F") return -3.6;
	if (rp == "R_1_F") return -2.8;
	if (rp == "R_2_F") return -41.9;

	return 0;
}

//----------------------------------------------------------------------------------------------------

real GetMeanHorizontalRelativeAlignment(string sector)
{
	if (sector == "45") return 38.05;
	if (sector == "56") return 39.15;

	return 0;
}

//----------------------------------------------------------------------------------------------------

real GetMeanVerticalAlignment(string rp)
{
	if (rp == "L_2_F") return 3.5;
	if (rp == "L_1_F") return 4.0;
	if (rp == "R_1_F") return 4.5;
	if (rp == "R_2_F") return 4.0;

	return 0;
}

//----------------------------------------------------------------------------------------------------

real GetMeanVerticalRelativeAlignment(string sector)
{
	if (sector == "45") return -1.32;
	if (sector == "56") return -1.17;

	return 0;
}
