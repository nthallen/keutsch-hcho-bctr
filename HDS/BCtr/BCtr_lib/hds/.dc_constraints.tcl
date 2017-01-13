#
# DesignChecker code/rule exclusions for library 'BCtr_lib'
#
# Created:
#          by - nort.UNKNOWN (NORT-XPS14)
#          at - 14:53:25 01/11/2017
#
# using Mentor Graphics HDL Designer(TM) 2016.1 (Build 8)
#
dc_exclude -design_unit {BitClk} -check {RuleSets\Essentials\Downstream Checks\Avoid Asynchronous Reset Release}
dc_exclude -design_unit {TriEn} -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets}
dc_exclude -design_unit {PMT_Input} -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets}
dc_exclude -design_unit {BCtrCtrl} -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets}
dc_exclude -design_unit {BCtrCtrl} -check {RuleSets\Essentials\Downstream Checks\Register Controllability}
dc_exclude -design_unit {BitClk} -check {RuleSets\Essentials\Downstream Checks\Register Controllability}
dc_exclude -design_unit {prdelay} -check {RuleSets\Essentials\Downstream Checks\Register Reset Control} -comment {Dumb}
dc_exclude -design_unit {BCtr_cfg} -check {RuleSets\Essentials\Downstream Checks\Register Reset Control} -comment {dumb}
dc_exclude -design_unit {BCtr_data} -check {RuleSets\Essentials\Downstream Checks\Register Reset Control} -comment {dumb}
dc_exclude -design_unit {syscon} -check {RuleSets\Essentials\Downstream Checks\Non Synthesizable Constructs} -comment {dumb}
dc_exclude -design_unit {syscon} -check {RuleSets\Essentials\Coding Practices\Matching Range} -comment {Just wrong}
dc_exclude -design_unit {syscon} -check {RuleSets\Essentials\Downstream Checks\Register Reset Control} -comment {dumb}
