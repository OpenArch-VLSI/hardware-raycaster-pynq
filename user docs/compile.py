import os,re
D=os.path.dirname(__file__)
L=chr(10)
parts={}
for fn in sorted(os.listdir(D)):
 m=re.match(r"(\d\d)_(\d+)\.part",fn)
 if m:
  k=int(m.group(1))
  if k not in parts:parts[k]=[]
  parts[k].append(open(os.path.join(D,fn),encoding="utf-8").read())
