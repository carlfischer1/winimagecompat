# nodelabel.py
# adds a label containing the specified Windows version on Windows nodes in the cluster
# that do not already have one

import requests
import json

ucp='https://52.158.239.214'
winverlabel = 'com.docker.ucp.node.windowsversion'
headers = {'content-type': 'application/json'}
params = {}
body = {}
 
# TODO get from command line input
winver = '10.0.14393.128'

# certificates and keys from UCP client bundle
#
# cert.bundle = cert.pem + key.pem
# used with requests cert parameter to specify client certificate and it's key 
cert = '/Users/carlfischer/Documents/nodelabel/cert.bundle2'
#
# ca = trusted CA
# used with verify option to specify the CA as used by the server
ca = '/Users/carlfischer/Documents/nodelabel/ca.pem'

# get set of nodes from UCP
resp = requests.get(ucp+'/nodes', verify=ca, cert=cert)
if resp.status_code != 200:
    resp.raise_for_status()
    exit
nodes = resp.json()

# check each node
# add label where necessary
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
            params['version'] = node.get('Version').get('Index')
            body = json.dumps(node.get('Spec'))
            # update node in UCP 
            resp = requests.post(ucp+'/nodes/'+node.get('ID')+'/update', params=params, data=body, headers=headers, verify=ca, cert=cert)
            if resp.status_code != 200:
                resp.raise_for_status()
                exit
