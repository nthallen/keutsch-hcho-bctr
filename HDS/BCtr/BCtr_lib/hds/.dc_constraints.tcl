#
# DesignChecker code/rule exclusions for library 'BCtr_lib'
#
# Created:
#          by - nort.UNKNOWN (NORT-XPS14)
#          at - 16:50:45 02/20/2017
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
dc_exclude -design_unit {temp_addr} -check {RuleSets\Essentials\Coding Practices\FSM Transitions} -comment {notstate}
dc_exclude -source_file {C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\HDS\BCtr\BCtr_lib\hdl\temp_addr_beh.vhdl} -start_line 26 -end_line 26 -check {RuleSets\Essentials\Downstream Checks\Register IO} -comment {OK}
dc_exclude -source_file {C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\HDS\BCtr\BCtr_lib\hdl\i2c_master_top.vhd} -start_line 81 -end_line 81 -check {RuleSets\Essentials\Downstream Checks\Initialization Assignments} -comment {OK}
dc_exclude -source_file {C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\HDS\BCtr\BCtr_lib\hdl\i2c_master_bit_ctrl.vhd} -start_line 416 -end_line 416 -check {RuleSets\Essentials\Coding Practices\Internally Generated Resets} -comment {OK}
dc_exclude -source_file {C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\HDS\BCtr\BCtr_lib\hdl\BCtr_data_beh.vhdl} -start_line 110 -end_line 110 -check {RuleSets\Essentials\Coding Practices\FSM Transitions} -comment {It does}
dc_exclude -design_unit {BCtr_syscon_wrapper_tester} -check {RuleSets\Essentials\Downstream Checks\Non Synthesizable Constructs} -comment {OK}
dc_exclude -source_file {C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\HDS\BCtr\BCtr_lib\hdl\aio_addr_beh.vhdl} -start_line 26 -end_line 26 -check {RuleSets\Essentials\Downstream Checks\Register IO} -comment {OK}
dc_exclude -source_file {C:\Users\nort.ARP\Documents\Exp\HCHO\BCtr\HDS\BCtr\BCtr_lib\hdl\aio_addr_beh.vhdl} -start_line 27 -end_line 27 -check {RuleSets\Essentials\Downstream Checks\Register IO} -comment {OK}
