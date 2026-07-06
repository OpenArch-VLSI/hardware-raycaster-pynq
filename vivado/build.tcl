set part_num "xc7z020clg400-1"
set proj_name "hardware-raycaster-pynq"
set proj_dir "./project"

create_project $proj_name $proj_dir -part $part_num -force

# Add RTL sources
add_files ../rtl/include/dvi_pkg.svh
add_files ../rtl/dvi/delay.sv
add_files ../rtl/dvi/dvi_sync.sv
add_files ../rtl/dvi/tmds_encoder.sv
add_files ../rtl/dvi/serializer.sv
add_files ../rtl/dvi/ds_buf.sv
add_files ../rtl/dvi/dvi_top.sv
add_files ../rtl/pynq_z2_top.sv

# Add constraints
add_files -fileset constrs_1 ../constraints/pynq-z2.xdc

# Set top module
set_property top pynq_z2_top [current_fileset]
update_compile_order -fileset sources_1

# Run Synthesis
launch_runs synth_1 -jobs 4
wait_on_run synth_1

# Check for synthesis success
if {[get_property PROGRESS [get_runs synth_1]] != "100%"} {
    puts "ERROR: Synthesis failed"
    exit 1
}

# Run Implementation
launch_runs impl_1 -jobs 4
wait_on_run impl_1

# Check for implementation success
if {[get_property PROGRESS [get_runs impl_1]] != "100%"} {
    puts "ERROR: Implementation failed"
    exit 1
}

# Generate Bitstream
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1

# Generate Reports
open_run impl_1
report_utilization -file ../docs/utilization.rpt
report_timing_summary -file ../docs/timing_summary.rpt

puts "Build completed successfully!"
