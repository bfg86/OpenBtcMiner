# Create clocks
create_clock [get_port wb_clk_i]    -name wb_clk   -period $::env(CLOCK_PERIOD)
create_clock [get_port user_clock2] -name core_clk -period $::env(CLOCK_PERIOD)

# Clock groups
set_clock_groups -name async_grp -asynchronous -comment "asynch group" \
  -group [get_clock wb_clk] \
  -group [get_clock core_clk]

# Clock margins
puts "\[INFO\]: Setting clock uncertainity to: $::env(SYNTH_CLOCK_UNCERTAINITY)"
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINITY) [get_clocks wb_clk]
set_clock_uncertainty $::env(SYNTH_CLOCK_UNCERTAINITY) [get_clocks core_clk]

# Clock transition
puts "\[INFO\]: Setting clock transition to: $::env(SYNTH_CLOCK_TRANSITION)"
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks wb_clk]
set_clock_transition $::env(SYNTH_CLOCK_TRANSITION) [get_clocks core_clk]


# I/O delay
set input_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
set output_delay_value [expr $::env(CLOCK_PERIOD) * $::env(IO_PCT)]
puts "\[INFO\]: Setting output delay to: $output_delay_value"
puts "\[INFO\]: Setting input delay to: $input_delay_value"

set_max_fanout $::env(SYNTH_MAX_FANOUT) [current_design]

set clk_input [get_port wb_clk_i]
set clk_indx [lsearch [all_inputs] $clk_input]
set all_inputs_wo_clk_tmp [lreplace [all_inputs] $clk_indx $clk_indx ""]
set clk_input [get_port user_clock2]
set clk_indx [lsearch $all_inputs_wo_clk_tmp $clk_input]
set all_inputs_wo_clk [lreplace $all_inputs_wo_clk_tmp $clk_indx $clk_indx ""]

#set rst_input [get_port resetn]
#set rst_indx [lsearch [all_inputs] $rst_input]
#set all_inputs_wo_clk_rst [lreplace $all_inputs_wo_clk $rst_indx $rst_indx ""]
set all_inputs_wo_clk_rst $all_inputs_wo_clk

# correct resetn
set_input_delay $input_delay_value  -clock [get_clocks wb_clk] $all_inputs_wo_clk_rst
#set_input_delay 0.0 -clock [get_clocks $::env(CLOCK_PORT)] {resetn}
set_output_delay $output_delay_value  -clock [get_clocks wb_clk] [all_outputs]

if { ![info exists ::env(SYNTH_CLK_DRIVING_CELL)] } {
    set ::env(SYNTH_CLK_DRIVING_CELL) $::env(SYNTH_DRIVING_CELL)
}

if { ![info exists ::env(SYNTH_CLK_DRIVING_CELL_PIN)] } {
    set ::env(SYNTH_CLK_DRIVING_CELL_PIN) $::env(SYNTH_DRIVING_CELL_PIN)
}

set_driving_cell -lib_cell $::env(SYNTH_DRIVING_CELL) -pin $::env(SYNTH_DRIVING_CELL_PIN) $all_inputs_wo_clk_rst

set_driving_cell -lib_cell $::env(SYNTH_CLK_DRIVING_CELL) -pin $::env(SYNTH_CLK_DRIVING_CELL_PIN) $clk_input

set cap_load [expr $::env(SYNTH_CAP_LOAD) / 1000.0]
puts "\[INFO\]: Setting load to: $cap_load"
set_load  $cap_load [all_outputs]

# Derate
puts "\[INFO\]: Setting timing derate to: [expr {$::env(SYNTH_TIMING_DERATE) * 10}] %"
set_timing_derate -early [expr {1-$::env(SYNTH_TIMING_DERATE)}]
set_timing_derate -late [expr {1+$::env(SYNTH_TIMING_DERATE)}]
