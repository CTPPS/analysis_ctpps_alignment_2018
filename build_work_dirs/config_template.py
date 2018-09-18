import sys 
import os
import FWCore.ParameterSet.Config as cms

sys.path.append(os.path.relpath("./"))
sys.path.append(os.path.relpath("../../"))

from config_common import config
from input_files import input_files

config.fill = $fill
config.xangle = $xangle
config.beta = $beta
config.dataset = "$dataset"

config.input_files = input_files
