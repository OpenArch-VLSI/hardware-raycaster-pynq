import os,nL=chr(10);OUT=r"C:\\Users\\nayak\\phase1_docs";B=L+L
def w(n,t):
 with open(os.path.join(OUT,n),"w",encoding="utf-8") as fh:fh.write(t)
 print(n)
