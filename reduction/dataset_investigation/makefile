all: process

process: process.cc
	g++ `root-config --libs` -lMinuit `root-config --cflags` -Wall -g\
		process.cc -o process
