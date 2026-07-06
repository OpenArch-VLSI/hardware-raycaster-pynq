import os,sys
OUT=os.path.dirname(os.path.abspath(__file__))
fname=sys.stdin.readline().strip()
data=sys.stdin.read()
open(os.path.join(OUT,fname),"w",encoding="utf-8").write(data)
print(fname)