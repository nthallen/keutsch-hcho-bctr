#
# DesignChecker code/rule exclusions for library 'BCtr_lib'
#
# Created:
#          by - nort.UNKNOWN (NORT-XPS14)
#          at - 16:51:05 10/19/2016
#
# using Mentor Graphics HDL Designer(TM) 2013.1b (Build 2)
#

dc_exclude -design_unit {BitClk} -check {RuleSets\Essentials\Downstream Checks\Avoid Asynchronous Reset Release}
dc_exclude -design_unit {TriEn} -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets}
dc_exclude -design_unit {PMT_Input} -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets}
dc_exclude -design_unit {BCtrCtrl} -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets}
dc_exclude -design_unit {BCtrCtrl} -check {RuleSets\Essentials\Downstream Checks\Register Controllability}
dc_exclude -design_unit {BitClk} -check {RuleSets\Essentials\Downstream Checks\Register Controllability}