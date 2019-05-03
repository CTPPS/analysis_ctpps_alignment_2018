import sys 
import os
import FWCore.ParameterSet.Config as cms

sys.path.append(os.path.relpath("./"))
sys.path.append(os.path.relpath("../../../../../"))

from config_base import *
from input_files import input_files

config.fill = 7206
config.xangle = 130
config.beta = 0.25
config.dataset = "DS1"

config.aligned = True

config.input_files = input_files

ApplyDefaultSettingsAlignmentSeptember()
