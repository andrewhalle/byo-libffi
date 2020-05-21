from ctypes import cdll

libadd = cdll.LoadLibrary('./libadd.so')
result = libadd.add(1,2,3,4,5,6,7,8,9,10)
print(result)
