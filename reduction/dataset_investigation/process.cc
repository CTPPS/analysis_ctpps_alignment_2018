#include <map>
#include <set>
#include <string>
#include <cstdio>
#include <cstring>

using namespace std;

int main(int argc, const char **argv)
{
	set<unsigned int> runs;
	map<string, map<unsigned int, unsigned int>> data; // map: stream -> (run -> events)

	for (int ai = 1; ai < argc; ++ai)
	{
		FILE *f = fopen(argv[ai], "r");

		unsigned int run = atoi(argv[ai]+10);

		//printf("%s --> %u\n", argv[ai], run);

		runs.insert(run);

		while (!feof(f))
		{
			char line[201];
			char *ret = fgets(line, 200, f);
			if (ret == NULL)
				break;

			//printf("%p <%s>\n", ret, line);

			char *stream = strtok(line, ",");
			char *ext = strtok(NULL, ",");
			char *s_events = strtok(NULL, ",");

			double d_events = atof(s_events);
			unsigned int events = (unsigned int) d_events;

			//printf("%s -- %s -- %u\n", stream, ext, events);

			data[stream][run] = events;
		}

		fclose(f);
	}
	
	printf(",");
	for (const auto &run : runs)
		printf("%u,,", run);
	printf("\n");

	for (auto &p : data)
	{
		printf("%s,", p.first.c_str());

		for (const auto &run : runs)
			printf("%u,,", p.second[run]);

		printf("\n");
	}

	return 0;
}
