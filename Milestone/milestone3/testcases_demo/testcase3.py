class A:
    def __init__(self):
        self.x: int = 1
        self.y: int = 312

    def add_func(self, a: int, b: int) -> int:
        a = self.x
        b = self.y
        return a + b


class B(A):
    def __init__(self):
        self.x = 1
        self.y = 316
        self.z : str = "Hi" 

    def sub_func(self, a: int, b: float) -> int:
        a = self.x
        b = self.y
        return a - b 


class Computer:
    cpu : int = 0

    def __init__(self):
        self.__maxprice: int = 900

    def sell(self) -> None:
        print("Selling Price:")
        print(self.__maxprice)

    def setMaxPrice(self, price: int) -> None:
        self.__maxprice = price


def main():
    a: A = A()
    b: B = B()
    
    e: int = a.add_func(a.x, a.y)
    f: int = b.add_func(b.x, b.y)
    g: int = b.sub_func(b.x, 3)
    print(e)
    print(f)
    print(g)


    c: Computer = Computer()
    c.sell()

    c.setMaxPrice(1000)
    c.sell()


if __name__ == "__main__":
    main()
