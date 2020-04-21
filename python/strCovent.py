def strCovent(spam):
    tmp=''
    for i in range(len(spam)):
        if(i == len(spam) -1 ):
            tmp+='and '+spam[i]
            return tmp
        else:
            tmp+=spam[i]+','

print(strCovent(['apples','bannanas','tofu','cats']))
