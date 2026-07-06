import os,glob
D=r"C:\\Users\\nayak\\phase1_docs"
for g in ["01_*.dat","02_*.dat","03_*.dat","04_*.dat","05_*.dat","06_*.dat","07_*.dat","08_*.dat","00_*.dat"]:
 p=[x for x in glob.glob(os.path.join(D,g))]
 p.sort()
 if p:
  n=g.split("_")[0]+".md"
 o=""
 for f in p:o+=open(f,encoding="utf-8").read()
 open(os.path.join(D,n),"w",encoding="utf-8").write(o)
  print(n)
w("01_test",open(r"C:\\Users\\nayak\\phase1_docs\\01_intro.dat").read())
