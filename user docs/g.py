import os
N=chr(10)
D=os.path.dirname(__file__)
def w(n,*lines):
 open(os.path.join(D,n),chr(119),encoding=chr(117)+chr(116)+chr(102)+chr(45)+chr(56)).write(N.join(lines))
 print(n)
