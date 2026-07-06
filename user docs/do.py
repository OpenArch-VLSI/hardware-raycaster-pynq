import os
N=chr(10)
P=chr(124)
D=os.path.dirname(__file__)
def w(n,t):
 open(os.path.join(D,n),chr(97),encoding=chr(117)+chr(116)+chr(102)+chr(45)+chr(56)).write(t)
 print(n)
w('04_memory.md',N.join(['# 04 - Memory Map','','## Memory arrays in the design','','| Name | Module/File | Width | Depth | Addr bits | Init source | Ports | Timing | Stores |','|---|---|---|---|---|---|---|---|---|']))
