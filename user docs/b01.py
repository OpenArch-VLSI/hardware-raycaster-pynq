import os
OUT=r"C:\\Users\\nayak\\phase1_docs"
L=chr(10)
p=os.path.join(OUT,"01_architecture_overview.md")
with open(p,"w") as fh:
 fh.write(L.join(["# 01 Architecture Overview","","Hardware raycaster in SystemVerilog. Wolfenstein-3D inspired."]));fh.write(L)
