class Computer:

    b: int = 0
    def __init__(self):
        self.__maxprice : int = 900

    def sell(self)->None:
        print("Selling Price: ")

    def setMaxPrice(self, price: int)->int:
        self.__maxprice = price



c: Computer = Computer()
c.sell()

# change the price
c.__maxprice = 1000
c.sell()
c.b = 10
d:int = c.b

# using setter function
c.setMaxPrice(1000)
c.sell()
a: int = c.setMaxPrice(100)
