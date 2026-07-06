import os
D=r"C:\\Users\\nayak\\phase1_docs"
L=chr(10)
def w(n,t):
 open(os.path.join(D,n),"w",encoding="utf-8").write(t)
 print(n)
