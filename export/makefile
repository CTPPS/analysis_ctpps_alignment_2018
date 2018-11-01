all: collect_alignments

collect_alignments: collect_alignments.cc ../alignment_classes.h fills_runs.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++14 -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc6_amd64_gcc630 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCorePythonParameterSet \
		collect_alignments.cc -o collect_alignments
