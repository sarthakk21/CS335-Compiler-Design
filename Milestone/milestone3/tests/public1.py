def bubbleSort(array: list[int]) -> None:
  i: int = 0
  n : int = len(array)
  j : int = 0
  swapped: int = 0
  temp : int = 0
  for i in range(n):
    swapped = 0
    j = 0
    for j in range(0, n - i - 1):
      if array[j] > array[j + 1]:
        temp = array[j]
        array[j] = array[j + 1]
        array[j + 1] = temp
        swapped = 1
    if not swapped:
      break
  print("Sorted Array in Ascending Order:")
  for i in range(n):
    print(array[i])

def main():
  data: list[int] = [-2, 45, 0, 11, -9, 1]
  bubbleSort(data)
  

if __name__ == "__main__":
  main()
