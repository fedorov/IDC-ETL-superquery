import sys
import itertools
sys.path.append('/usr/local/lib/python3.7/site-packages')

import google.cloud.bigquery as bq

cl1 = bq.Client()


collection_col={}
columnSet=set()
collectionList=[]

fo=open("./tcga_collections.txt","r+");
for line in fo:
    collectionA=line.rstrip('\n')
    collection=collectionA.split(' ')[0]
    #print(collection)
    collectionList.append(collection)
    collection_col[collection]={}

    
    q3 = ('select * from `chc-tcia.'+collection+'.INFORMATION_SCHEMA.COLUMNS` ')
    query_job=cl1.query(q3)
    rows=query_job.result()
    for row in rows:
        col=str(row.column_name)+"("+str(row.data_type)+")"
        collection_col[collection][col]=1
        columnSet.add(col)        



columnList=sorted(columnSet)


for column in columnList:
    print("\t"+column, end="")
print ()


for collection in collectionList:
    print(collection, end="")
    for column in columnList:
        if column in collection_col[collection]:
            print("\t1", end="")
        else:
            print("\t0", end="")
    print()


''' QUERY = (
    'SELECT * FROM `chc-tcia.4d_lung.4d_lung` '
    'LIMIT 10')
q1 = ('select * from `chc-tcia.4d_lung.INFORMATION_SCHEMA.COLUMNS` limit 1')

q2 = ('select sum(size_bytes)/pow(10,9) from `chc-tcia.4d_lung.__TABLES__` limit 1')

query_job = cl1.query(q2)  # API request
rows = query_job.result()  # Waits for query to finish

for row in rows:
    #print(row.column_name, row.data_type, row.is_nullable)
    print(row[0])
'''
