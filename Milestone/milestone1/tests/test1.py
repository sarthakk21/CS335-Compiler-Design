#Start of the code

global maximum, memo 

def _lis(arr,n):
    global maximum
    if n==1:
        return 1
    if memo[n] != -1:
        return memo[n]
    maxEndingHere=1
    for i in range(1,n):
        res=_lis(arr,i)
        if arr[i-1]<arr[n-1] and res+1>maxEndingHere:
            maxEndingHere=res+1
    memo[n]=maxEndingHere
    maximum=max(maximum,maxEndingHere)
    return maxEndingHere

def lis(arr):
    global maximum, memo 
    n=len(arr)
    memo = [-1]*(n+1)
    maximum=1
    _lis(arr,n)
    return maximum

def main():
    #example test case
    arr=[10,22,9,33,
         21,50,41,
         
         60]
    n=len(arr)
    print("Length of lis is",lis(arr))
    print("The Array is : ")
    for i in arr:
      print(i, end = ' ')
    print()

if __name__=="__main__":
  main()

#End of the code  
