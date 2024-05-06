def insertionSort(arr: list[int]) -> None:
    n: int= len(arr)  
    key: int = 0
    i: int = 0
    j: int = 0
 
    for i in range(1, n):  
        key = arr[i] 
        j = i-1
        while j >= 0 and key < arr[j]:  
            arr[j+1] = arr[j]  # Shift elements to the right
            j -= 1
        arr[j+1] = key  
    i = 0
    print("Sorted Array in Ascending Order:")
    for i in range(n):
        print(arr[i])

def maxSubarraySum(arr : list[int], n : int) -> int:
    maxi : int = -999999
    i : int = 0
    j : int = 0
    k : int = 0
    for i in range(n):
        for j in range(i, n):
            # subarray = arr[i.....j]
            summ : int = 0

            # add all the elements of subarray:
            for k in range(i, j+1):
                summ += arr[k]

            if summ > maxi:
                maxi = summ

    return maxi


def main():
    
    arr : list[int] = [12, 11, 13, 5, 6]
    insertionSort(arr)

    data : list[int]= [-2, 1, -3, 4, -1, 2, 1, -5, 4]
    n : int = len(data)
    maxSum : int = maxSubarraySum(data, n)
    print("The maximum subarray sum is:")
    print(maxSum)

if __name__ == "__main__":
    main()
