def findPages(arr : list[int], n : int, m : int) -> int:
    # book allocation impossible
    if m > n:
        return -1

    low : int = 0
    high : int = 0
    i : int = 0
    for i in range(n):
        if arr[i] > low:
            low = arr[i]
        high += arr[i]
    

    pages : int = 0
    x : int = 0
    students : int = 1
    pagesStudent : int = 0
    for pages in range(low, high + 1):
        students = 1
        pagesStudent = 0
        i = 0
        x = 0
        for i in range(n):
            x = pagesStudent + arr[i]
            if x <= pages:
                # add pages to current student
                pagesStudent += arr[i]
            else:
                # add pages to next student
                students += 1
                pagesStudent = arr[i]
        # print(x)
        if students == m:
            return pages
    return low

def main():

    arr : list[int] = [25, 46, 28, 49, 24]
    n : int = 5
    m : int = 4
    ans : int = findPages(arr, n, m)
    print("The answer is:")
    #Output should be 71
    print(ans)
