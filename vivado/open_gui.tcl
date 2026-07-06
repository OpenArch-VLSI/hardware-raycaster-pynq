# Vivado script to open the project in the GUI for inspection
# Run with: C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat -mode gui -source vivado\open_gui.tcl

set part xc7z020clg400-1
set top_module pynq_test_pattern_top

create_project -in_memory -part $part

# Add RTL files
read_verilog -sv [glob ./rtl/include/*.svh]
read_verilog -sv [glob ./rtl/dvi/*.sv]
read_verilog -sv [glob ./rtl/*.sv]

# Add constraints
read_xdc ./constraints/pynq_z2.xdc

puts "Files loaded into in-memory project. You can now browse the RTL, open Elaborated Design, etc."
