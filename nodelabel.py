# nodelabel.py
# adds a label with the specified Windows version to Windows nodes in a UCP cluster

# usage: python3 .\nodelabel.py {UCP URL} {Windows version}
#    ex: python3 .\nodelabel.py https://172.16.4.12 10.0.14393.125
#
# covers the following cases
#   1 - non-Windows nodes (no change)
#   2 - Windows nodes with an existing label (no change)
#   3 - preserving existing labels
#
# requires
#   A client bundle downloaded from UCP, with contents unzipped in the working directory
#   A 'cert.bundle' file created by concatenating cert.pem + key.pem

import requests
import json
import os
import sys

#ucp = 'https://52.158.239.214'
clientbundlepath = os.getcwd()
winverlabel = 'com.docker.ucp.node.windowsversion'
headers = {'content-type': 'application/json'}
params = {}
body = {}
 
# get parameters from command line
assert (len(sys.argv) == 3), "UCP URL or version argument not specified"
ucp = sys.argv[1]
winver = sys.argv[2]

# certificates and keys from UCP client bundle
#
# cert.bundle = cert.pem + key.pem
#   used with requests cert parameter to specify client certificate and it's key 
cert = clientbundlepath+'/cert.bundle'
#
# ca = trusted CA
#   used with requests verify parameter to specify the CA used by the server
ca = clientbundlepath+'/ca.pem'

# get set of nodes from UCP
resp = requests.get(ucp+'/nodes', verify=ca, cert=cert)
if resp.status_code != 200:
    resp.raise_for_status()
    exit
nodes = resp.json()

# check each node and add label where necessary
for node in nodes:
    print ('{} {}'.format("Processing node ID: ", node.get('ID')))
    # windows nodes only
    if node.get('Description',{}).get('Platform',{}).get('OS') != "windows":
        print("    Node OS != Windows, skipping")
    else:
       if winverlabel in node.get('Spec',{}).get('Labels',{}):
            print ("    Existing label found, skipping")
       else:
           # new label required
            print ("    Setting new label")
            node['Spec']['Labels'][winverlabel] = winver
            data = json.dumps(node.get('Spec'))
            params['version'] = node.get('Version').get('Index')
            # update node in UCP 
            resp = requests.post(ucp+'/nodes/'+node.get('ID')+'/update', params=params, data=data, headers=headers, verify=ca, cert=cert)
            if resp.status_code != 200:
                resp.raise_for_status()
                exit
