def factorial_iterative(n):
    if n == 0:
        return 1
    result = 1 
    for i in range(1,n+1):
        result *= i
    return result

def factorial_recursive(n):
    if n == 0:
        return 1
    result = n * factorial_recursive(n-1)
    return result

def sum_up_ton(n):
    total = 0 
    for i in range(1,n+1):
        total += i
    return total

def average_upto_n(n):
    if n == 0:
        return 0
    sum = sum_up_ton(n)
    average_upto_n = sum/n  
    return average_upto_n

def print_numbers_up_to_n(n):
    print("Numbers upto",n)
    for i in range(1,n+1):
        print(i, end = ' ')
    print()

def main():
    n = int(input("Enter the number to calculate factorial: "))
    print("Factorial of",n,"using iterative method=",factorial_iterative(n))
    print("Factorial of",n,"using recursive method=",factorial_recursive(n))
    print("Sum upto",n,"=",sum_up_ton(n))
    print("Average upto",n,"=",average_upto_n(n))
    print_numbers_up_to_n(n)

if __name__=="__main__":
    main()
