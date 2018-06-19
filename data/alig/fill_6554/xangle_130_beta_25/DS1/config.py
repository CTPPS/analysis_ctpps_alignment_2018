import sys 
import os
import FWCore.ParameterSet.Config as cms

sys.path.append(os.path.relpath("./"))
sys.path.append(os.path.relpath("../../../../../"))

from config_base import config
from input_files import input_files

config.input_files = input_files

config.cut1_apply = True
config.cut1_c = +0.52

config.cut2_apply = True
config.cut2_c = -0.64

config.cut3_apply = True
config.cut3_a = -1.
config.cut3_c = +1.02

config.cut4_apply = True
config.cut4_a = -1.
config.cut4_c = +0.54
