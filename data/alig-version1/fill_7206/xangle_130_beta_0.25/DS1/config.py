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

config.matching = cms.PSet(
  reference_datasets = cms.vstring("default"),

  rp_L_2_F = cms.PSet(
    sh_min = cms.double(-1),
    sh_max = cms.double(+1)
  ),
  rp_L_1_F = cms.PSet(
    sh_min = cms.double(-1),
    sh_max = cms.double(+1)
  ),
  rp_R_1_F = cms.PSet(
    sh_min = cms.double(-1),
    sh_max = cms.double(+1)
  ),
  rp_R_2_F = cms.PSet(
    sh_min = cms.double(-1),
    sh_max = cms.double(+1)
  )
)

config.x_alignment_meth_o = cms.PSet(
  rp_L_2_F = cms.PSet(
    x_min = cms.double(3.5),
    x_max = cms.double(15.),
  ),
  rp_L_1_F = cms.PSet(
    x_min = cms.double(3.5),
    x_max = cms.double(15.),
  ),
  rp_R_1_F = cms.PSet(
    x_min = cms.double(3.5),
    x_max = cms.double(15.),
  ),
  rp_R_2_F = cms.PSet(
    x_min = cms.double(3.5),
    x_max = cms.double(15.),
  )
)

config.y_alignment = cms.PSet(
  rp_L_2_F = cms.PSet(
    x_min = cms.double(3.),
    x_max = cms.double(8.),
  ),
  rp_L_1_F = cms.PSet(
    x_min = cms.double(3.),
    x_max = cms.double(7.),
  ),
  rp_R_1_F = cms.PSet(
    x_min = cms.double(2.3),
    x_max = cms.double(5.5),
  ),
  rp_R_2_F = cms.PSet(
    x_min = cms.double(2.3),
    x_max = cms.double(5.5),
  )
)
