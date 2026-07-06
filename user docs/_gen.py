import os,sys
OUT=r"C:\\Users\\nayak\\phase1_docs"
def w(n,t):
 p=os.path.join(OUT,n)
 with open(p,"w",encoding="utf-8") as fh:
  fh.write(t)
 print(f"[OK] {n}")

doc01 = """############################################################
01 - Architecture Overview
############################################################
...building...
"""
w("01_architecture_overview.md", doc01)
