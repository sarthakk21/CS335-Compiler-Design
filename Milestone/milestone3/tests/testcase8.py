class A:
    def __init__(self) -> None:
        self.x: int = 1
        self.y: int = 3

    def add_func(self, a: int, b: int) -> int:
        a = self.x
        b = self.y
        return a + b
    
class B(A):
    def __init__(self) -> None:
        self.x = 1
        self.y = 3
        self.z : int = 4 
        

    def sub_func(self, a: int, b: float) -> int:
        a = self.x
        b = self.y
        return a - b
    
class C(B):
    def __init__(self) -> None:
        self.x = 1
        self.y = 3
        self.z = 4
        self.bruh : int = 5

    def mul_func(self, a: int, b: float) -> int:
        a = self.x
        b = self.y
        return a * b
    
def main():
    a: A = A()
    b: B = B()
    c: C = C()
 
    f: int = c.add_func(b.x, b.y)
    g: int = c.sub_func(c.x, c.z)
    h: int = c.mul_func(c.x, 3)

    print(f)
    print(g)
    print(h)
