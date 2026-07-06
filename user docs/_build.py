import os,glob
OUT=r"C:\\Users\\nayak\\phase1_docs"
for p in glob.glob(os.path.join(OUT,"*.part")):
 n=os.path.basename(p)[:-5]
 with open(p) as fh: c=fh.read()
 open(os.path.join(OUT,n),"w").write(c)
 print(n)
