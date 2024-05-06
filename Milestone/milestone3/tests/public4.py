def binarySearch( x:int, low: int, high: int, array: list[int]) -> int:
  n : int = len(array)
  i : int = 0
  # print(n)
  # print(x)
  # print(high)
  # print(low)
  # for i in range(0, n):
  #   print(array[i])
  while low <= high:
    # for i in range(0, n):
    #   print(array[i])
    # print("-----------------------")
    # print(array[1])
    mid: int = low + (high -low) // 2
    # print(mid)
    if array[mid] == x:
      # print("hi")
      return mid
    elif array[mid] < x:
      # print("hi2")
      low = mid + 1
    else:
      # print("hi3")
      high = mid - 1
    # print("hi")
  return -1


def main():
  array:list[int] = [3, 4, 5, 6, 10, 11]
  n : int = len(array)
  result: int = binarySearch(10, 0, n - 1,array)

  if result != -1:
    print("Element is present at index:")
    print(result)
  else:
    i:int = 0
    print("Element is not present")


if __name__ == "__main__":
  main()
