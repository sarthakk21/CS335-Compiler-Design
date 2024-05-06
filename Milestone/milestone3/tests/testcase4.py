def function1(x: int) -> int:
    if x > 0:
        return 1
    return 0


def function2(x: int) -> int:
    result: int = function1(x)
    if result == 1:
        return 1
    else:
        return 2

def function3(x: int) -> int:
    result1: int = function2(x)
    if result1 == 1:
        return 1
    elif result1 == 0:
        return 0
    else:
        return -1

def function4(x: int) -> int:
    result2:int = function3(x)
    if result2 == 1:
        return 1
    elif result2 == 0:
        return 0
    else:
        return -1

def function5(x: int) -> int:
    result3: int = 0
    i : int = function1(x) - 1
    for i in range(x):
        result3 += i
    return result3

def function6(x: int) -> int:
    result4:int = 0
    i: int = 0
    while x > 0:
        result4 += x
        x -= 1
    return result4

def function7(x: int) -> int:
    result5: int = 0
    i: int = 0
    for i in range(x):
        result5 += i
        if i == 3:
            break
    return result5

def main():
    a: int = function1(5)
    print(a) # Output: 1

    a = function2(-2)
    print(a) # Output: 2

    a = function3(0)
    print(a) # Output: -1

    a = function4(-10)
    print(a) # Output: -1

    a = function5(5)
    print(a) #Output: 10

    a = function6(-2)
    print(a) #Output: 0

    a = function7(10)
    print(a) #Output: 6

if __name__ == "__main__":
    main()
