data: list[float] = [-2.3, 3.14, 0.9, 11, -9.1]
i : int =0

def compute_min() -> float:
  min_value : int = 0
  for i in range(5,10,2):
    if not min_value:
      min_value = data[i]
    elif data[i] < min_value:
      min_value = data[i]
  return min_value


def compute_avg() -> float:
  sum : int = 0
  for i in range(5):
    sum += data[i]
  return sum / len(data)


def main() -> None:
  min_value: float = compute_min()
  print("Minimum value: ")
  print(min_value)
  avg_value: float = compute_avg()
  print("Average value: ")
  print(avg_value)


if __name__ == "__main__":
  main()
