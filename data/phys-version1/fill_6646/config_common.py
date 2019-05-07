import sys 
import os
import FWCore.ParameterSet.Config as cms

sys.path.append(os.path.relpath("../../../../../"))

from config_base import *

ApplyDefaultSettings2()
config.sector_56.cut_h_c = -39.26 - 0.35 + 0.39
config.sector_56.cut_v_c = 1.49 - 0.5 + 0.80
