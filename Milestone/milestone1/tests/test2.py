def fibona(n):
    if n <= 0:
        return []
    elif n == 1:
        return [0]
    sequence = list() #Pre-allocate list
    sequence[0] = 0
    sequence[1] = 1
    for i in range(2,n):
        sequence[i] = sequence[i-1] + sequence[i-2]
    return sequence

def generate_fibonacci_by_limit(limit):
    a, b = 0, 1
    sequence = [a]
    while b <= limit:
        sequence += [b]
        a, b = b, a+b
    return sequence
def sum_of_sequence(sequence):
    sum = 0
    for i in sequence: sum += i
    print("Sum succesfully calculated")

def prod_of_sequence(sequence):
    prod = 0;
    for i in sequence: 
        prod *= i
    print("Product succesfully calculated")


def main(): 
    n = int(input("Enter the length of fibonacci sequence: "))
    fib_sequence = fibona(n);
    print("Fibonacci sequence of length=",n)
    print(fib_sequence);
    sum_fib_sequence = sum_of_sequence(fib_sequence)
    print("Sum of fibonacci sequence=",sum_fib_sequence)
    limit = 100;
    fib_sequence_by_limit = generate_fibonacci_by_limit(limit)
    print("Fibonacci sequence upto limit=",limit)
    print(fib_sequence_by_limit)


if __name__=="__main__":
    main()
