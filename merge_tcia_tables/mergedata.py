import sys
import itertools
import json
import pprint
sys.path.append('/usr/local/lib/python3.7/site-packages')

import google.cloud.bigquery as bq
cl1 = bq.Client()


skip={}
added={}
outA=[]
fo=open("./skip_columns.txt","r+");
for line in fo:
    word=line.rstrip('\n')
    skip[word]=1
fo.close()



fo=open("./tcga_collections.txt","r+");
for line in fo:
    added={}
    collectionA=line.rstrip('\n').split(' ')
    table_name=collectionA[0]
    project_short_name=collectionA[1]
 
    col1A=table_name.split('_')
    nm=col1A[1]
    fileo="./forms/"+nm+".json"
    f1 = open(fileo)
    curForm=json.load(f1) 
    #print(curForm)
    insA=["project_short_name"]
    selA=["\'"+project_short_name+"\'"]
    for item in curForm:
        if not (item['name'] in added) and not (item['name'] in skip):
            insA.append(item['name'])
            selA.append(item['name'])  
            added[item['name']]=1
    f1.close()
    #print(insA)
    #print(selA)
    insStr=", ".join(insA)
    selStr=", ".join(selA)

    q = ('insert into `idc-dev-etl.idc.dicom_all` ('+insStr+') select '+selStr+'  from `chc-tcia.'+table_name+'.'+table_name+'`')
    query_job=cl1.query(q)
    query_job.result()
    #rowt = next((x for x in query_job.result()),None)[0]
    #print(str(rowt))
    #sys.exit(0)
    print(table_name)



#pprint.pprint(outA)
#json.dumps(outA)
#print(str(len(outA)))
#print(outA)

    

