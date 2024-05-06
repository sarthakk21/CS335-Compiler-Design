i : int = 0
j : int = 1
def bubbleSort(array: list[int]) -> None:
  for i in range(5):
    swapped: bool = False
    for j in range(0, 5):
      if array[j] > array[j + 1]:
        temp : int = array[j]
        array[j] = array[j + 1]
        array[j + 1] = temp
        swapped = True
    if not swapped:
      break


def main() -> None:
  data: list[int] = [-2, 45, 0, 11, -9]
  bubbleSort(data)

  print("Sorted Array in Ascending Order:")
  for i in range(5):
    print(data[i])


if __name__ == "__main__":
  main()
