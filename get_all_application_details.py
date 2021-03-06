#!/usr/bin/env python
from pymongo import MongoClient
import re
def get_all_prd_vlae():
    try:    
        regex_production_application = re.compile(".*\-amsterdam\-.*|.*\-bangalore\-.*|.*\-AMERICA\-.*",re.IGNORECASE)
Regexrtppapplication = re.compile(".*\-france\-.*",reIGNORECASE )
Regexrtp1papplication = re.compile(".*\-africa\-.*",reIGNORECASE )
        
        client = MongoClient("mongodb://**SECURITY******")
        db = client['openshift_broker']
        cursor = db.applications.find( { "default_gear_size" : regex_production_application })
        
        for document in cursor:
                   print document[u'domain_namespace']+","+document[u'canonical_name']+","+" ".join([x[u'n'] for x in document[u'members']])+","+" ".join([x[u'fqdn'] for x in document[u'aliases']])
            
    except KeyError, e:
        print 'I got a KeyError - reason "%s"' % str(e)                   
    return cursor

if __name__ == "__main__":
    get_all_prd_vlae()
