all: distributions match x_alignment_meth_o x_alignment_relative y_alignment y_alignment_alt

distributions: distributions.cc config.h stat.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCoreParameterSetReader \
			distributions.cc -o distributions

match: match.cc config.h stat.h alignment_classes.h default_reference.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCoreParameterSetReader \
			match.cc -o match

x_alignment_meth_o: x_alignment_meth_o.cc config.h stat.h alignment_classes.h default_reference.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCoreParameterSetReader \
			x_alignment_meth_o.cc -o x_alignment_meth_o

x_alignment_relative: x_alignment_relative.cc config.h stat.h alignment_classes.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCoreParameterSetReader \
			x_alignment_relative.cc -o x_alignment_relative

y_alignment: y_alignment.cc config.h stat.h alignment_classes.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCoreParameterSetReader \
			y_alignment.cc -o y_alignment

y_alignment_alt: y_alignment_alt.cc config.h stat.h alignment_classes.h
	g++ `root-config --libs` -lMinuit `root-config --cflags` \
		-g -O3 --std=c++1z -Wall -Wextra -Wno-attributes\
		-I$(CMSSW_RELEASE_BASE)/src \
		-L$(CMSSW_RELEASE_BASE)/lib/slc7_amd64_gcc820 \
		-lDataFormatsFWLite -lDataFormatsCommon -lDataFormatsCTPPSDetId -lFWCoreParameterSet -lFWCoreParameterSetReader \
			y_alignment_alt.cc -o y_alignment_alt
