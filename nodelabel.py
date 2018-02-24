import requests
import json

ucp='https://52.158.239.214'
winverlabel = 'engine.labels.windowsversion'
# cert.bundle = cert.pem + key.pem
# used with cert option to specify client certificate and it's key 
cert = '/Users/carlfischer/Documents/nodelabel/cert.bundle2'

# ca = trusted CA
# used with verify option to specify the CA as used by the server
ca = '/Users/carlfischer/Documents/nodelabel/ca.pem'

resp = requests.get(ucp+'/nodes', verify = ca, cert=cert)

# error handling on resp != 200

nodes = resp.json()
for node in nodes:
    print ('{} {}'.format("Processing node ID: ", node.get('ID')))
    match = 0
    # Only Windows nodes
    if node.get('Description',{}).get('Platform',{}).get('OS') == "windows":
        for label in node.get('Description',{}).get('Engine',{}).get('Labels',{}):
            if label == winverlabel:
                print ("    Existing label found, skipping")
                match = 1
            else:
                print(label)
        if match == 0:
            print ("    Setting new label")
    else:
        print("    Node OS != Windows, skipping")
