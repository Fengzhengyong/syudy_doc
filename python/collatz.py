def collatz(number):
    if number%2==0:
        print(number//2)
        return number//2
    elif number%2==1:
        print(3*number+1)
        return 3*number+1
    else:
        return

def userInput():
    print('Enter number：')
    num=input()
    try:
        num=int(num)
    except ValueError:
        print('ValueError: please input a int number！')
    while num!=1:
        num=collatz(num)

userInput()

