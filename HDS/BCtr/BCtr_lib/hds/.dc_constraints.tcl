#
# DesignChecker code/rule exclusions for library 'BCtr_lib'
#
# Created:
#          by - nort.UNKNOWN (NORT-XPS14)
#          at - 13:13:58 01/ 9/2017
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
