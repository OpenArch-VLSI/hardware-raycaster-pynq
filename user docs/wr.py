import os
L=chr(10)
D=os.path.dirname(__file__)
def w(n,t):
 open(os.path.join(D,n),chr(119)).write(t)
 print(n)

#DOC01
w("01_architecture_overview.md",L.join(["# 01 Architecture Overview","","## What the design does"]))
