all: distributions match

distributions: distributions.cc config.h stat.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		--std=c++14 -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc6_amd64_gcc630 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCorePythonParameterSet \
			distributions.cc -o distributions

match: match.cc config.h stat.h alignment_classes.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		--std=c++14 -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc6_amd64_gcc630 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCorePythonParameterSet \
			match.cc -o match
