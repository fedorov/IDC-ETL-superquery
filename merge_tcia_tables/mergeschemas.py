import sys
import itertools
import json
import pprint
sys.path.append('/usr/local/lib/python3.7/site-packages')


skip={}
added={}
outA=[]
fo=open("./skip.txt","r+");
for line in fo:
    word=line.rstrip('\n')
    skip[word]=1
fo.close()



fo=open("./tcga_collections.txt","r+");
for line in fo:
    collectionA=line.rstrip('\n').split(' ')
    col1=collectionA[0]
    col2=collectionA[1]
 
    col1A=col1.split('_')
    nm=col1A[1]
    fileo="./forms/"+nm+".json"
    f1 = open(fileo)
    curForm=json.load(f1) 
    #print(curForm)
    for item in curForm:
        if not (item['name'] in added) and not (item['name'] in skip):
            outA.append(item)
            added[item['name']]=1
    f1.close()

pprint.pprint(outA)
#json.dumps(outA)
#print(str(len(outA)))
#print(outA)

    

