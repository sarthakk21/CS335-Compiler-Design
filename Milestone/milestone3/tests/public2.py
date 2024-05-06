def compute_min(data : list[int]) -> int:
  # data: list[int] = [1, 2, 3, 4, 5]
  min_value : int = 99999999
  i : int = 0
  n : int = len(data)
  for i in range(0,n):
    # print(data[i])
    if data[i] < min_value:
      min_value = data[i]
      # print(min_value)
  # print(min_value)
  return min_value


def compute_avg(data : list[int]) -> int:
  # data: list[int] = [1, 2, 3, 4, 5]
  sum : int = 0
  i : int = 0
  n : int = len(data)
  for i in range(0,n):
    sum += data[i]
  # n : int = len(data)
  return sum /len(data)


def main():
  data: list[int] = [8,8,9,10,15]
  
  min_value: int = compute_min(data)
  print("Minimum value: ")
  print(min_value)
  avg_value: int = compute_avg(data)
  print("Average value: ")
  print(avg_value)


# if __name__ == "__main__":
#   main()
