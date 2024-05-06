def add(a:int, b:int)->int:
    # Adds two integers 
    return a + b

def power(c:int, d:int)->int:
   # Raises 'c' to the power of 'd'  
   result: int = 1
   while d > 0:
       result *= c
       d = d - 1
   return result

def sum_of_powers(e: int, f: int) -> int:
    # Recursively calculates the sum of powers of 'e' from 1 to 'f'
    g: int = 0
    h: int = 0
    k : int = 0
    if f == 0:
        return 0
    else:
        # Recursive call with decremented power
        g = f - 1
        h = power(e, f)
        k = sum_of_powers(e, g)
        return add(h, k)


def fibonacci(n : int)-> int:
    # Returns the nth Fibonacci number
    i: int = 2
    j: int = 3
    if n < 0:
        return -1
 
    elif n == 0:
        return 0
 
    elif n == 1:   
        return 1
    
    elif n == 2:
        return 1
    else:
        # Recursive calls to calculate the two preceding Fibonacci numbers
        res : int  = fibonacci(n-1) + fibonacci(n-2)
        return res
    
def main(): 
    # Calculate and print the 10th Fibonacci number which should be 5%
    n: int = 10
    result : int = fibonacci(n)
    print("Fibonacci number at position 10 is: ")
    print(result)

    # Calculate and print the sum of powers for base '3' up to the exponent '4' which should be 120
    first:int = 3
    second :int = 4
    result_second:int = sum_of_powers(first,second)
    print("Sum of powers for base 3 up to the exponent 4 is: ")
    print(result_second)

if __name__ == "__main__":
    main()
