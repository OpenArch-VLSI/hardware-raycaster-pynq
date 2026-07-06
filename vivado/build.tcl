# Vivado build script for PYNQ-Z2 hardware-raycaster port
# Run with: vivado -mode batch -source vivado/build.tcl

set part xc7z020clg400-1
set top_module pynq_test_pattern_top

create_project -in_memory -part $part

# Add RTL files
read_verilog -sv [glob ./rtl/include/*.svh]
read_verilog -sv [glob ./rtl/dvi/*.sv]
read_verilog -sv [glob ./rtl/*.sv]

# Add constraints
read_xdc ./constraints/pynq_z2.xdc

# Synthesis
synth_design -top $top_module -part $part

# Optimization
opt_design

# Placement
place_design

# Routing
route_design

# Generate reports
report_timing_summary -file ./docs/timing_summary.rpt
report_utilization -file ./docs/utilization.rpt

# Write Bitstream
write_bitstream -force pynq_test_pattern.bit

puts "Build complete. Bitstream generated."
