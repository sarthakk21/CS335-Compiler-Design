def is_prime(n: int) -> int:
    if n <= 1:
        return 0
    if n <= 3:
        return 1
    
    if n % 2 == 0 or n % 3 == 0:
        return 0
    i: int = 5
    while i * i <= n:
        if n % i == 0 or n % (i + 2) == 0:
            return 0
        i += 6
    return 1

def main():
    numbers: list[int] = [2, 3, 4, 5, 6, 7, 8, 9, 10, 29, 35, 37]
    i: int = 11
    k: int = numbers[i]
    print(k)
    res: int = is_prime(numbers[i])
    if is_prime(k) == 1:
        print("Prime number")
    else:
        print("Not a prime number") 

if __name__ == "__main__":
    main()


