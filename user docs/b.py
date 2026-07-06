import os
L=chr(10);D=r"C:\\Users\\nayak\\phase1_docs"
def w(n,t):
 open(os.path.join(D,n),"w",encoding="utf-8").write(t)
 print(n)
