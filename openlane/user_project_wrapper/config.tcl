# SPDX-FileCopyrightText: 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# SPDX-License-Identifier: Apache-2.0

# Base Configurations. Don't Touch
# section begin

set ::env(PDK) $::env(PDK)
set ::env(STD_CELL_LIBRARY) "sky130_fd_sc_hd"

# YOU ARE NOT ALLOWED TO CHANGE ANY VARIABLES DEFINED IN THE FIXED WRAPPER CFGS 
source $::env(DESIGN_DIR)/fixed_dont_change/fixed_wrapper_cfgs.tcl

# YOU CAN CHANGE ANY VARIABLES DEFINED IN THE DEFAULT WRAPPER CFGS BY OVERRIDING THEM IN THIS CONFIG.TCL
source $::env(DESIGN_DIR)/fixed_dont_change/default_wrapper_cfgs.tcl

set script_dir [file dirname [file normalize [info script]]]

set ::env(DESIGN_NAME) user_project_wrapper
#section end

# User Configurations

## Source Verilog Files
set ::env(VERILOG_FILES) "\
	$::env(CARAVEL_ROOT)/verilog/rtl/defines.v \
	$script_dir/../../verilog/rtl/user_project_wrapper.v \
	$script_dir/../../verilog/rtl/BtcMiner.v \
	$script_dir/../../verilog/rtl/BtcMinerRegs.v \
	$script_dir/../../verilog/rtl/BtcMinerCore.v \
	$script_dir/../../verilog/rtl/Sha256Ppl.v"

## Clock configurations. Note: custom SDC file
set ::env(CLOCK_PORT) "wb_clk_i"
set ::env(CLOCK_PERIOD) 10
set ::env(BASE_SDC_FILE) "$::env(DESIGN_DIR)/constraints.sdc"

## Synthesis
set ::env(SYNTH_MAX_FANOUT) 1000
set ::env(SYNTH_ADDER_TYPE) "YOSYS"
set ::env(SYNTH_MUX4_MAP) ""
set ::env(SYNTH_MUX_MAP) ""
set ::env(SYNTH_BUFFERING) 1
set ::env(SYNTH_SIZING) 1
set ::env(SYNTH_STRATEGY) {AREA 3}

## Floorplan
set ::env(DESIGN_IS_CORE) 1

## Placement
set ::env(PL_BASIC_PLACEMENT) 0
set ::env(PL_TARGET_DENSITY) 0.48
set ::env(CELL_PAD) 4


## Routing
set ::env(GLB_RT_MAX_DIODE_INS_ITERS) 3
set ::env(ROUTING_CORES) 8

##
set ::env(DIODE_INSERTION_STRATEGY) 4

