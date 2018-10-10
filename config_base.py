import FWCore.ParameterSet.Config as cms

config = cms.PSet(
    fill = cms.uint32(0),
    xangle = cms.uint32(0),
    beta = cms.double(0),
    dataset = cms.string(""),

    alignment_corrections = cms.PSet(
      rp_L_2_F = cms.PSet(
        de_x = cms.double(0.)
      ),
      rp_L_1_F = cms.PSet(
        de_x = cms.double(0.)
      ),
      rp_R_1_F = cms.PSet(
        de_x = cms.double(0.)
      ),
      rp_R_2_F = cms.PSet(
        de_x = cms.double(0.)
      )
    ),

    aligned = cms.bool(False),

    n_si = cms.double(4.),

    sector_45 = cms.PSet(
	  cut_h_apply = cms.bool(True),
	  cut_h_a = cms.double(-1),
	  cut_h_c = cms.double(0.),
	  cut_h_si = cms.double(0.2),

	  cut_v_apply = cms.bool(True),
	  cut_v_a = cms.double(-1.07),
	  cut_v_c = cms.double(0.),
	  cut_v_si = cms.double(0.15),

      nr_x_slice_min = cms.double(7),
      nr_x_slice_max = cms.double(19),
      nr_x_slice_w = cms.double(0.2),

      fr_x_slice_min = cms.double(46),
      fr_x_slice_max = cms.double(58),
      fr_x_slice_w = cms.double(0.2),
    ),

    sector_56 = cms.PSet(
	  cut_h_apply = cms.bool(True),
	  cut_h_a = cms.double(-1),
	  cut_h_c = cms.double(0.),
	  cut_h_si = cms.double(0.2),

	  cut_v_apply = cms.bool(True),
	  cut_v_a = cms.double(-1.07),
	  cut_v_c = cms.double(0.),
	  cut_v_si = cms.double(0.15),

      nr_x_slice_min = cms.double(6),
      nr_x_slice_max = cms.double(17.),
      nr_x_slice_w = cms.double(0.2),

      fr_x_slice_min = cms.double(45),
      fr_x_slice_max = cms.double(57.),
      fr_x_slice_w = cms.double(0.2),
    ),

    matching = cms.PSet(
      reference_datasets = cms.vstring("default"),

      rp_L_2_F = cms.PSet(
        sh_min = cms.double(-43),
        sh_max = cms.double(-41)
      ),
      rp_L_1_F = cms.PSet(
        sh_min = cms.double(-4.2),
        sh_max = cms.double(-2.4)
      ),
      rp_R_1_F = cms.PSet(
        sh_min = cms.double(-3.6),
        sh_max = cms.double(-1.8)
      ),
      rp_R_2_F = cms.PSet(
        sh_min = cms.double(-43.2),
        sh_max = cms.double(-41.2)
      )
    ),

    x_alignment_meth_x = cms.PSet(
      rp_L_2_F = cms.PSet(
        x_min = cms.double(49),
        x_max = cms.double(57.),
      ),
      rp_L_1_F = cms.PSet(
        x_min = cms.double(11.),
        x_max = cms.double(18.),
      ),
      rp_R_1_F = cms.PSet(
        x_min = cms.double(7.5),
        x_max = cms.double(18.),
      ),
      rp_R_2_F = cms.PSet(
        x_min = cms.double(47.),
        x_max = cms.double(57.),
      )
    ),

    x_alignment_meth_y = cms.PSet(
      rp_L_2_F = cms.PSet(
        x_min = cms.double(46.),
        x_max = cms.double(56.),
      ),
      rp_L_1_F = cms.PSet(
        x_min = cms.double(7.),
        x_max = cms.double(18.),
      ),
      rp_R_1_F = cms.PSet(
        x_min = cms.double(6),
        x_max = cms.double(13.),
      ),
      rp_R_2_F = cms.PSet(
        x_min = cms.double(45.),
        x_max = cms.double(52.),
      )
    ),

    x_alignment_meth_o = cms.PSet(
      rp_L_2_F = cms.PSet(
        x_min = cms.double(48.),
        x_max = cms.double(57.),
      ),
      rp_L_1_F = cms.PSet(
        x_min = cms.double(10.),
        x_max = cms.double(19.),
      ),
      rp_R_1_F = cms.PSet(
        x_min = cms.double(8.),
        x_max = cms.double(17.),
      ),
      rp_R_2_F = cms.PSet(
        x_min = cms.double(47.),
        x_max = cms.double(56.),
      )
    ),

    x_alignment_relative = cms.PSet(
      rp_L_2_F = cms.PSet(
        x_min = cms.double(0.),
        x_max = cms.double(0.),
      ),
      rp_L_1_F = cms.PSet(
        x_min = cms.double(7.5),
        x_max = cms.double(12.),
      ),
      rp_R_1_F = cms.PSet(
        x_min = cms.double(6.),
        x_max = cms.double(10.),
      ),
      rp_R_2_F = cms.PSet(
        x_min = cms.double(0.),
        x_max = cms.double(0.),
      )
    ),

    y_alignment = cms.PSet(
      rp_L_2_F = cms.PSet(
        x_min = cms.double(45.5),
        x_max = cms.double(49.),
      ),
      rp_L_1_F = cms.PSet(
        x_min = cms.double(6.5),
        x_max = cms.double(10.),
      ),
      rp_R_1_F = cms.PSet(
        x_min = cms.double(5.5),
        x_max = cms.double(7.5),
      ),
      rp_R_2_F = cms.PSet(
        x_min = cms.double(45.),
        x_max = cms.double(48.),
      )
    ),

    y_alignment_alt = cms.PSet(
      rp_L_2_F = cms.PSet(
        x_min = cms.double(0.),
        x_max = cms.double(0.),
      ),
      rp_L_1_F = cms.PSet(
        x_min = cms.double(7.),
        x_max = cms.double(19.),
      ),
      rp_R_1_F = cms.PSet(
        x_min = cms.double(6),
        x_max = cms.double(17.),
      ),
      rp_R_2_F = cms.PSet(
        x_min = cms.double(0.),
        x_max = cms.double(0.),
      )
    )
)

#----------------------------------------------------------------------------------------------------

def ApplyDefaultSettingsAlignmentApril():
  config.sector_45.cut_h_a = -1
  config.sector_45.cut_h_c = 0.

  config.sector_45.cut_v_a = -1
  config.sector_45.cut_v_c = 0.

  config.sector_56.cut_h_a = -1
  config.sector_56.cut_h_c = 0.16

  config.sector_56.cut_v_a = -1
  config.sector_56.cut_v_c = -0.13

  config.sector_45.nr_x_slice_min = 2
  config.sector_45.nr_x_slice_max = 16

  config.sector_45.fr_x_slice_min = 2
  config.sector_45.fr_x_slice_max = 16

  config.sector_56.nr_x_slice_min = 3
  config.sector_56.nr_x_slice_max = 16.5

  config.sector_56.fr_x_slice_min = 2.5
  config.sector_56.fr_x_slice_max = 16.5

  config.x_alignment_meth_x.rp_L_2_F.x_min = 2.
  config.x_alignment_meth_x.rp_L_2_F.x_max = 15.5

  config.x_alignment_meth_x.rp_L_1_F.x_min = 2.
  config.x_alignment_meth_x.rp_L_1_F.x_max = 15.5

  config.x_alignment_meth_x.rp_R_1_F.x_min = 3.
  config.x_alignment_meth_x.rp_R_1_F.x_max = 16.

  config.x_alignment_meth_x.rp_R_2_F.x_min = 3.
  config.x_alignment_meth_x.rp_R_2_F.x_max = 16.

  config.x_alignment_meth_y.rp_L_2_F.x_min = 2.
  config.x_alignment_meth_y.rp_L_2_F.x_max = 15.

  config.x_alignment_meth_y.rp_L_1_F.x_min = 2.
  config.x_alignment_meth_y.rp_L_1_F.x_max = 15.

  config.x_alignment_meth_y.rp_R_1_F.x_min = 3.
  config.x_alignment_meth_y.rp_R_1_F.x_max = 16.

  config.x_alignment_meth_y.rp_R_2_F.x_min = 3.
  config.x_alignment_meth_y.rp_R_2_F.x_max = 16.

  config.x_alignment_meth_o.rp_L_2_F.x_min = 6.
  config.x_alignment_meth_o.rp_L_2_F.x_max = 15.

  config.x_alignment_meth_o.rp_L_1_F.x_min = 6.
  config.x_alignment_meth_o.rp_L_1_F.x_max = 15.

  config.x_alignment_meth_o.rp_R_1_F.x_min = 5.
  config.x_alignment_meth_o.rp_R_1_F.x_max = 14.

  config.x_alignment_meth_o.rp_R_2_F.x_min = 5.
  config.x_alignment_meth_o.rp_R_2_F.x_max = 14.


def ApplyDefaultSettingsAlignmentSeptember():
  ApplyDefaultSettingsAlignmentApril()
  config.sector_45.cut_h_c = -0.06
  config.sector_45.cut_v_c = +0.03
  config.sector_56.cut_h_c = +0.08
  config.sector_56.cut_v_c = +0.09


def ApplyDefaultSettings1():
  config.sector_45.cut_h_c = -38.55 + 0.35
  config.sector_45.cut_v_c = 1.63 - 0.20
  config.sector_56.cut_h_c = -39.26 - 0.35
  config.sector_56.cut_v_c = 1.49 - 0.5

def ApplyDefaultSettings2():
  config.sector_45.cut_h_c = -38.55 + 0.35
  config.sector_45.cut_v_c = 1.63 - 0.20
  config.sector_56.cut_h_c = -39.26 - 0.35
  config.sector_56.cut_v_c = 1.49 - 0.5

def ApplyDefaultSettings3():
  config.sector_45.cut_h_c = -38.55 + 0.35
  config.sector_45.cut_v_c = 1.63 - 0.20
  config.sector_56.cut_h_c = -39.26 + 0.20
  config.sector_56.cut_v_c = 1.49 + 0.17

def ApplyDefaultSettings4():
  config.sector_45.cut_h_c = -38.55 + 0.5
  config.sector_45.cut_v_c = 1.63 - 1.15
  config.sector_56.cut_h_c = -39.26 + 0.25
  config.sector_56.cut_v_c = 1.49 - 0.85
