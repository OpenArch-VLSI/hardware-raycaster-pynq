import os
L=chr(10)
D=r"C:\\Users\\nayak\\phase1_docs"
def w(n,t):
 open(os.path.join(D,n),"w",encoding="utf-8").write(t)
 print(n)

w("01_architecture_overview.md",L.join(["# 01 Architecture Overview","","## What the design does","","Hardware raycaster in SystemVerilog, Wolfenstein-3D inspired.","640 rays/frame through 2D map. Textured walls at 640x480 with 24-bit color over DVI.","Player pos and camera via 6 keys. Double-buffered. FSM-based resource sharing.","Target: Gowin Tang Primer 20K, yosys-slang + nextpnr + Apicula.","","---"]))
w("01_architecture_overview.md",L.join(["## Top-level block diagram (Mermaid)","","```mermaid","graph TD","    OSC[27MHz osc] -- arrow -- PLL[rPLL 27-252MHz]","    PLL -- arrow -- serial_clk 252MHz -- DVI[dvi_top]"]))

###
