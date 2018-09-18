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
config.xangle = 130
config.beta = 0.30
config.dataset = "DS1"

ApplyDefaultSettingsAlignment()
