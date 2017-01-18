# Definitional proc to organize widgets for parameters.
proc init_gui { IPINST } {
  ipgui::add_param $IPINST -name "Component_Name"
  #Adding Page
  set Page_0 [ipgui::add_page $IPINST -name "Page 0"]
  ipgui::add_param $IPINST -name "ADDR_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "BUILD_NUMBER" -parent ${Page_0}
  ipgui::add_param $IPINST -name "FAIL_WIDTH" -parent ${Page_0}
  ipgui::add_param $IPINST -name "INSTRUMENT_ID" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N_BOARDS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N_CTR_CHANNELS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "N_INTERRUPTS" -parent ${Page_0}
  ipgui::add_param $IPINST -name "SW_WIDTH" -parent ${Page_0}


}

proc update_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to update ADDR_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.ADDR_WIDTH { PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to validate ADDR_WIDTH
	return true
}

proc update_PARAM_VALUE.BUILD_NUMBER { PARAM_VALUE.BUILD_NUMBER } {
	# Procedure called to update BUILD_NUMBER when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.BUILD_NUMBER { PARAM_VALUE.BUILD_NUMBER } {
	# Procedure called to validate BUILD_NUMBER
	return true
}

proc update_PARAM_VALUE.FAIL_WIDTH { PARAM_VALUE.FAIL_WIDTH } {
	# Procedure called to update FAIL_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.FAIL_WIDTH { PARAM_VALUE.FAIL_WIDTH } {
	# Procedure called to validate FAIL_WIDTH
	return true
}

proc update_PARAM_VALUE.INSTRUMENT_ID { PARAM_VALUE.INSTRUMENT_ID } {
	# Procedure called to update INSTRUMENT_ID when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.INSTRUMENT_ID { PARAM_VALUE.INSTRUMENT_ID } {
	# Procedure called to validate INSTRUMENT_ID
	return true
}

proc update_PARAM_VALUE.N_BOARDS { PARAM_VALUE.N_BOARDS } {
	# Procedure called to update N_BOARDS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_BOARDS { PARAM_VALUE.N_BOARDS } {
	# Procedure called to validate N_BOARDS
	return true
}

proc update_PARAM_VALUE.N_CTR_CHANNELS { PARAM_VALUE.N_CTR_CHANNELS } {
	# Procedure called to update N_CTR_CHANNELS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_CTR_CHANNELS { PARAM_VALUE.N_CTR_CHANNELS } {
	# Procedure called to validate N_CTR_CHANNELS
	return true
}

proc update_PARAM_VALUE.N_INTERRUPTS { PARAM_VALUE.N_INTERRUPTS } {
	# Procedure called to update N_INTERRUPTS when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.N_INTERRUPTS { PARAM_VALUE.N_INTERRUPTS } {
	# Procedure called to validate N_INTERRUPTS
	return true
}

proc update_PARAM_VALUE.SW_WIDTH { PARAM_VALUE.SW_WIDTH } {
	# Procedure called to update SW_WIDTH when any of the dependent parameters in the arguments change
}

proc validate_PARAM_VALUE.SW_WIDTH { PARAM_VALUE.SW_WIDTH } {
	# Procedure called to validate SW_WIDTH
	return true
}


proc update_MODELPARAM_VALUE.BUILD_NUMBER { MODELPARAM_VALUE.BUILD_NUMBER PARAM_VALUE.BUILD_NUMBER } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.BUILD_NUMBER}] ${MODELPARAM_VALUE.BUILD_NUMBER}
}

proc update_MODELPARAM_VALUE.INSTRUMENT_ID { MODELPARAM_VALUE.INSTRUMENT_ID PARAM_VALUE.INSTRUMENT_ID } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.INSTRUMENT_ID}] ${MODELPARAM_VALUE.INSTRUMENT_ID}
}

proc update_MODELPARAM_VALUE.N_INTERRUPTS { MODELPARAM_VALUE.N_INTERRUPTS PARAM_VALUE.N_INTERRUPTS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_INTERRUPTS}] ${MODELPARAM_VALUE.N_INTERRUPTS}
}

proc update_MODELPARAM_VALUE.N_BOARDS { MODELPARAM_VALUE.N_BOARDS PARAM_VALUE.N_BOARDS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_BOARDS}] ${MODELPARAM_VALUE.N_BOARDS}
}

proc update_MODELPARAM_VALUE.ADDR_WIDTH { MODELPARAM_VALUE.ADDR_WIDTH PARAM_VALUE.ADDR_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.ADDR_WIDTH}] ${MODELPARAM_VALUE.ADDR_WIDTH}
}

proc update_MODELPARAM_VALUE.FAIL_WIDTH { MODELPARAM_VALUE.FAIL_WIDTH PARAM_VALUE.FAIL_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.FAIL_WIDTH}] ${MODELPARAM_VALUE.FAIL_WIDTH}
}

proc update_MODELPARAM_VALUE.SW_WIDTH { MODELPARAM_VALUE.SW_WIDTH PARAM_VALUE.SW_WIDTH } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.SW_WIDTH}] ${MODELPARAM_VALUE.SW_WIDTH}
}

proc update_MODELPARAM_VALUE.N_CTR_CHANNELS { MODELPARAM_VALUE.N_CTR_CHANNELS PARAM_VALUE.N_CTR_CHANNELS } {
	# Procedure called to set VHDL generic/Verilog parameter value(s) based on TCL parameter value
	set_property value [get_property value ${PARAM_VALUE.N_CTR_CHANNELS}] ${MODELPARAM_VALUE.N_CTR_CHANNELS}
}

