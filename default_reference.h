string GetDefaultReference(unsigned int /*fill*/, unsigned int xangle, double beta)
{
	unsigned int xangle_def = (cfg.xangle > 0) ? xangle : 160;
	double beta_def = (cfg.beta > 0) ? beta : 0.3;

	char buf[100];
	sprintf(buf, "data/alig-version3/fill_6554/xangle_%u_beta_%.2f/DS1", xangle_def, beta_def);

	/*
	if (xangle == 160 && fabs(beta - 0.3) < 1E-3)
		sprintf(buf, "data/alig-version2/fill_6554/xangle_%u_beta_%.2f/DS1", xangle_def, beta_def);
	*/

	return buf;
}
