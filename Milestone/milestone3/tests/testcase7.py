class LALRParser():

  def __init__(self, myname_: str, clrname_: str, srname_: str):
    self.a: str = myname_
    z : int = 6
    self.b: str = clrname_
    self.c: str = srname_
    self.d: int = z
  

  def print_name(self):
    print("SLR name:")
    print(self.a)
    print("CLR name:")
    print(self.b)
    print("LALR name:")
    print(self.c)
    print(self.d)
  


def main():
  obj: LALRParser = LALRParser("LALR", "CLR", "Shift-Reduce")

  obj.b = "helloo"

  obj.print_name()


if __name__ == "__main__":
  main()
