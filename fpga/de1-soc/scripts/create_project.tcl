package require ::quartus::project

# --------------------------------------------------------------------
# Paths
# --------------------------------------------------------------------

set script_dir [file dirname [file normalize [info script]]]
set fpga_dir   [file normalize "$script_dir/.."]
set repo_dir   [file normalize "$fpga_dir/../.."]
set build_dir  [file normalize "$fpga_dir/build"]

# Create build directory if it does not exist
file mkdir $build_dir

# --------------------------------------------------------------------
# Project configuration
# --------------------------------------------------------------------

set project_name "avalon-mm-led-demo"
set revision_name "avalon-mm-led-demo"
set top_level     "led_ctrl_hw_top"
set device        "5CSEMA5F31C6"


# --------------------------------------------------------------------
# Open existing project or create a new one
# --------------------------------------------------------------------

cd $fpga_dir

set qpf_file "$fpga_dir/$project_name.qpf"

if {[file exists $qpf_file]} {
    puts "Opening existing Quartus project: $qpf_file"

    project_open \
        -revision $revision_name \
        $project_name
} else {
    puts "Creating new Quartus project: $qpf_file"

    project_new \
        $project_name \
        -revision $revision_name
}


set_global_assignment -name DEVICE $device
set_global_assignment -name TOP_LEVEL_ENTITY $top_level

# Place compilation outputs, reports, and programming files in build/
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "build"

# --------------------------------------------------------------------
# RTL
# --------------------------------------------------------------------

set_global_assignment \
  -name SYSTEMVERILOG_FILE \
  "$repo_dir/rtl/avalon_mm_led_ctrl.sv"

# --------------------------------------------------------------------
# DUT Top module 
# --------------------------------------------------------------------

set_global_assignment \
  -name SYSTEMVERILOG_FILE \
  "$repo_dir/rtl/led_ctrl_hw_top.sv"


# --------------------------------------------------------------------
# Constraints
# --------------------------------------------------------------------


# LEDs
set_location_assignment PIN_V16 -to led_o[0]
set_location_assignment PIN_W16 -to led_o[1]
set_location_assignment PIN_V17 -to led_o[2]
set_location_assignment PIN_V18 -to led_o[3]
set_location_assignment PIN_W17 -to led_o[4]
set_location_assignment PIN_W19 -to led_o[5]
set_location_assignment PIN_Y19 -to led_o[6]
set_location_assignment PIN_W20 -to led_o[7]
set_location_assignment PIN_W21 -to led_o[8]
set_location_assignment PIN_Y21 -to led_o[9]


for {set i 0} {$i < 10} {incr i} {
    set_instance_assignment -name CURRENT_STRENGTH_NEW 16MA -to "led_o\[$i\]"
    set_instance_assignment -name SLEW_RATE 1 -to "led_o\[$i\]"
    set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to "led_o\[$i\]"
}

# Clock and reset 
set_location_assignment PIN_AF14 -to clk_i
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to clk_i

set_location_assignment PIN_AB12 -to rst_i
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to rst_i


 set_global_assignment \
     -name SDC_FILE \
     "$fpga_dir/constraints/clock.sdc"

export_assignments
project_close

puts "Created Quartus project:"
puts "  Project : $fpga_dir/$project_name.qpf"
puts "  Build   : $build_dir"
puts "  Device  : $device"
puts "  Top     : $top_level"
