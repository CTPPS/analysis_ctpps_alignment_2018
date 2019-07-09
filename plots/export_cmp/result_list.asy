string repoDir = "/afs/cern.ch/work/j/jkaspar/work/software/ctpps/development/ctpps_initial_proton_reconstruction_CMSSW_10_2_0/CMSSW_10_2_0/src/RecoCTPPS/ProtonReconstruction/data/alignment/2018/";

string files[], f_labels[];
pen f_pens[];

//files.push(repoDir + "collect_alignments_2018_11_02.3.out"); f_labels.push("2018\_11\_02.3"); f_pens.push(blue);
//files.push(repoDir + "fit_alignments_2019_05_20.1.out"); f_labels.push("2019\_05\_20.1"); f_pens.push(red);
files.push(repoDir + "fit_alignments_2019_07_01.out"); f_labels.push("2019\_07\_01"); f_pens.push(heavygreen);

files.push("../../export/fit_alignments_2019_07_08.out"); f_labels.push("2019\_07\_08"); f_pens.push(red);
