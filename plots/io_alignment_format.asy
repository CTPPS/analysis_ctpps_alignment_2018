struct AlignmentResult
{
	real sh_x, sh_x_unc;
	real sh_y, sh_y_unc;
};

//----------------------------------------------------------------------------------------------------

struct AlignmentResults
{
	string label;
	AlignmentResult results[];
};

//----------------------------------------------------------------------------------------------------

int atoi(string s)
{
	if (s == "NAN") return -1;
	if (s == "INF") return -1;
	
	return (int) s;
}

//----------------------------------------------------------------------------------------------------

real atof(string s)
{
	if (s == "NAN") return -1;
	if (s == "INF") return -1;
	
	return (real) s;
}

//----------------------------------------------------------------------------------------------------

void PrintAlignmentResults(AlignmentResults arc[])
{
	for (AlignmentResults ar : arc)
	{
		write("[" + ar.label + "]");

		for (int id : ar.results.keys)
		{
			AlignmentResult a = ar.results[id];
			write(format("id=%i,", id) + format("sh_x=%.3f", a.sh_x));
		}
	}
}

//----------------------------------------------------------------------------------------------------

int LoadAlignmentResults(string fn, AlignmentResults arc[])
{
	file f = input(fn, check=false);
	if (error(f))
	{
		write("ERROR: can't open file `"+fn+"'.");
		close(f);
		return 1;
	}

	AlignmentResults buf;
	bool buf_empty = true;

	while (!eof(f))
	{
		string line = f;

		// skip empty linese
		if (length(line) == 0)
			continue;

		// process block definition
		if (find(line, "[") == 0)
		{
			if (!buf_empty)
				arc.push(buf);

			buf = new AlignmentResults;
			buf.label = substr(line, 1, length(line)-2);
			buf_empty = false;

			continue;
		}

		// process block contents
		string bits[] = split(line, ",");
		int id;
		bool id_set = false;
		AlignmentResult ar;
		for (string bit : bits)
		{
			string d[] = split(bit, "=");
			if (d[0] == "id")
			{
				id = atoi(d[1]);
				id_set = true;
				continue;
			}

			if (d[0] == "sh_x")
			{
				ar.sh_x = atof(d[1]);
				continue;
			}

			if (d[0] == "sh_x_unc")
			{
				ar.sh_x_unc = atof(d[1]);
				continue;
			}

			if (d[0] == "sh_y")
			{
				ar.sh_y = atof(d[1]);
				continue;
			}

			if (d[0] == "sh_y_unc")
			{
				ar.sh_y_unc = atof(d[1]);
				continue;
			}

			write("ERROR: unknown tag \"" + d[0] + "\".");
		}

		if (id_set)
		{
			buf.results[id] = ar;
		} else {
			write("ERROR: id not set in line \"" + line + "\".");
		}
	}

	if (!buf_empty)
		arc.push(buf);

	close(f);
	return 0;
}
