if __name__ == "__main__":
    n = 10
    print("Multiplication table up to:",n)
    for i in range(1,n+1):
        for j in range(1,n+1):
            product = i*j
            print(i,"*",j,"=",i*j)
            if j == n:
                print()

    for num in range(2,n+1):
        is_prime = True
        for i in range (2, int(num/2)+1):
            if (num%i) == 0:
                is_prime = False
                break
        if is_prime:
            print(num,"is a prime number")
        else:   
            print(num,"is not a prime number")
    print("End of the code")

    print("Even and odd numbers upto",n)
    for i in range(1,n+1):
        if i%2 == 0:
            print(i,"is even")
        else:
            print(i,"is odd")

    for num in range(1,n+1):
        if num%3 == 0 and num%5 == 0:
            print("FizzBuzz")
        elif num%3 == 0:
            print("Fizz")
        elif num%5 == 0:
            print("Buzz")
        else:
            print(num)

    print("Countdown from",n)   
    countdown = n
    while countdown > 0:
        print(countdown)
        countdown -= 1
    print("Blast off!")
