import os,base64
D=os.path.dirname(__file__)
def d(n,b):
 open(os.path.join(D,n),"wb").write(base64.b64decode(b))
 print(n)
