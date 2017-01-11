onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /bctr_tb/clk
add wave -noupdate /bctr_tb/En
add wave -noupdate /bctr_tb/Trigger
add wave -noupdate /bctr_tb/DRdy
add wave -noupdate -radix decimal /bctr_tb/RData
add wave -noupdate /bctr_tb/RE
add wave -noupdate -radix decimal /bctr_tb/U_0/U_1/NAcnt
add wave -noupdate -radix decimal /bctr_tb/U_0/U_1/NBcnt
add wave -noupdate -radix decimal /bctr_tb/U_0/U_1/NCcnt
add wave -noupdate /bctr_tb/U_0/U_1/current_state
add wave -noupdate /bctr_tb/U_0/U_1/Empty1
add wave -noupdate /bctr_tb/U_0/U_1/Empty2
add wave -noupdate /bctr_tb/U_0/U_1/WE1
add wave -noupdate /bctr_tb/U_0/U_1/WE2
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {750 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 214
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {5341 ns} {5572 ns}
