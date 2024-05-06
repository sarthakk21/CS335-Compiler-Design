
def main():

  data : list[int] = [50,52,53,54,55]
  a : int = 45
  b : int = 3

  i : int = 0
  for i in range(5):
    print(data[i])
  for i in range(5):
    data[i] = i
  for i in range(5):
    print(data[i])
  x : int = 8 + data[2] + data[b]
  print(x)
  c : int = data[1] + 10
  data[2] += c + 1
  data[2] -= 5
  data[2] *= 2
  print(data[2])

if __name__ == "__main__":
  main()
  


