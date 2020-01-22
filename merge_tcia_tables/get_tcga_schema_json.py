import sys
import itertools
sys.path.append('/usr/local/lib/python3.7/site-packages')


fo=open("./tcga_collections.txt","r+");
for line in fo:
    collectionA=line.rstrip('\n').split(' ')
    col1=collectionA[0]
    col2=collectionA[1]
 
    col1A=col1.split('_')
    nm=col1A[1]
    print("bq show --format=prettyjson chc-tcia:"+col1+"."+col1+" | jq \'.schema.fields\' > ./schemas/"+nm+".json")
    

