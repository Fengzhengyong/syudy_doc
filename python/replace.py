#! python3
import re

def MadLibs(fileString):
    replaceReg=re.compile(r'(ADJECTIVE|NOUN|ADVERB|VERB)')
    replaceStr=replaceReg.findall(fileString)
    print(replaceStr)
    for key in range(len(replaceStr)):
        print('Enter an '+ replaceStr[key].lower())
        new=input()
        fileString=replaceReg.sub(''+new, fileString)
    print(fileString)
    return fileString

file=open('E:\\study_doc\\syudy_doc\\python\\test.txt','r')
fileString=file.read()
file.close()
fileString=MadLibs(fileString)
print(fileString)
file=open('E:\\study_doc\\syudy_doc\\python\\test.txt','w')
file.write(fileString)
file.close()

    
    
