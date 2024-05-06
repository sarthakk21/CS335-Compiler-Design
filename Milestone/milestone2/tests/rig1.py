
def main():
    a1 : int = 5
    a2 : int = 5.5
    a3 : int = True
    # a4 : int = "Hello1"
    # a5 : int = hello
    a1 = a2 + a3 - 1
    a1 = -a2 * a3 # minus not handled
    a1 = a2 / -a3 # minus not handled
    a1 = a2 // a3
    a1 = a2 % a3
    a1 = a2 ** a3 # power not handled
    a1 = a2 == a3
    a1 = a2 != a3
    a1 += a2 + a3
    a1 -= a2 * a3
    a1 *= a2 ** a3
    a1 /= a2 > a3
    a1 %= a2 / a3
    a1 **= a2
    
    a1 = 10
    a1 &= 10
    a1 |= 10
    a1 = a1 & a3
    a1 = a1
    a1 = a1 | a3
    a1 = a1 ^ a3
    a1 = a3 << 2
    a1 = 2 << a3
    a1 = a3 >> a3
    a1 = ~a3 # not handled
    
    a1 = a2 < a3
    a1 = a2 > a3
    a1 = a2 >= a3
    a1 = a2 <= a3
    b1 : float = 6.1
    b2 : float = 6
    b3 : float = True
    # b4 : float = "Hello2"
    # b5 : float = hello
    c1 : str = "Hi"
    # c2 : str = hi
    # c3 : str = True
    # c4 : str = 1
    # c5 : str = 1.5
    d1 : bool = True
    d2 : bool = 35
    # d2 : bool = 35.5
    
if __name__ == '__main__' :
  main()

