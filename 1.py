from dynamic_array import Array

a = Array("i", [1, 2, 3])
b = Array("i", [])
d = [1, 2, 3]
e = "123"
print(type(a), type(tuple(a)))
print(a == tuple(a))  
print(a == e)  
