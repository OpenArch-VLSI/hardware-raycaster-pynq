import os
def w(n):
 p=os.path.join(os.path.dirname(__file__),n)
 if os.path.exists(p+r".part"):
  c=open(p+r".part").read()
  open(p,"w").write(c)
  print(n)
