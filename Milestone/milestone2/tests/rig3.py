class A:

  def __init__(self):
    self.x1: int = 1
    self.y1: float = 3.14

  def fu1(self, a: int, b: float) -> int:
    a = self.x1
    b = self.y1

    return 0


class B(A):

  def __init__(self):
    self.x2 : int = 1
    self.y2 : int = 3.14
    self.z2: str = "I am new"
    A.__init__(self)

  def fu(self, a: int, b: float) -> str:
    a = self.x1
    b = self.y2
    A.fu1(self, a, b)

    return self.z2

def foo (c:int, d: int) -> int:
  return c 

def main():
  a: A = A()
  b: B = B()
  # foo(a.x, a.y, b.z)
  i: int = 0
  a.fu1(a.x1, a.y1)
  f : str = b.fu(b.x1, b.y2)
  # foo(a.x, a.y)


if __name__ == '__main__':
  main()
