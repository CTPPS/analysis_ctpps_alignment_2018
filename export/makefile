all: collect_alignments fit_alignments

collect_alignments: collect_alignments.cc ../alignment_classes.h fills_runs.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCorePythonParameterSet \
			collect_alignments.cc -o collect_alignments

fit_alignments: fit_alignments.cc ../alignment_classes.h fills_runs.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCorePythonParameterSet \
			fit_alignments.cc -o fit_alignments
