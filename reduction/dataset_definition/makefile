all: process_mapping

process_mapping: process_mapping.cc
	g++ --std=c++11 -Wall -Wextra `root-config --libs` -lMinuit `root-config --cflags` \
		process_mapping.cc -o process_mapping
