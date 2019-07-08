all: make_fits

make_fits: make_fits.cc ../alignment_classes.h ../export/fills_runs.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc6_amd64_gcc700 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCorePythonParameterSet \
			make_fits.cc -o make_fits
