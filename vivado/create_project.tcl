# Vivado script to generate a GUI project (.xpr)
# Run with: C:\AMDDesignTools\2025.2\Vivado\bin\vivado.bat -mode batch -source vivado\create_project.tcl

set project_name "hardware_raycast_pynq"
set part xc7z020clg400-1

# Create the project in the vivado/project directory
create_project $project_name ./vivado/project -part $part -force

# Add RTL files
add_files [glob ./rtl/include/*.svh]
add_files [glob ./rtl/dvi/*.sv]
add_files [glob ./rtl/*.sv]
set_property top pynq_test_pattern_top [current_fileset]

# Add constraints
add_files -fileset constrs_1 ./constraints/pynq_z2.xdc

# Let Vivado automatically discover the hierarchy
update_compile_order -fileset sources_1

puts "Project created successfully!"
