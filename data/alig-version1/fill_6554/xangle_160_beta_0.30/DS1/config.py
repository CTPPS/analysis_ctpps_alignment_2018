import sys 
import os
import FWCore.ParameterSet.Config as cms

sys.path.append(os.path.relpath("./"))
sys.path.append(os.path.relpath("../../../../../"))

from config_base import *
from input_files import input_files

config.input_files = input_files

config.aligned = True

config.fill = 6554
config.xangle = 160
config.beta = 0.30
config.dataset = "DS1"

ApplyDefaultSettingsAlignmentApril()

config.sector_45.cut_h_c = 0.04
config.sector_45.cut_v_c = +0.07
config.sector_56.cut_h_c = 0.10
config.sector_56.cut_v_c = -0.01
