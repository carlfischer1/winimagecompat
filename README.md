# Windows image compatibility
Testing, samples, and scripts for Windows image compatibility runbook

## git
```
git clone https://github.com/carlfischer1/winimagecompat.git
```
```
git config --global user.name "Your Name"
```
```
git config --global user.email you@example.com
```

## Reducing the overhead of maintaining custom labels on each node
The Windows Server run book is based on labels that contain the Windows version running on each node, and service constraints referencing those labels to bind a service built on a given Windows version to hosts running the matching version.

Unfortunately the ```docker node update``` command can only be run on Swarm masters, so it can't easily(?) be used to set node labels based on worker settings.

Here are two alternate methods to automate setting labels for worker nodes containing their Windows version:

### Powershell script to set engine label in daemon config


### UCP API to set node labels
Another option is to use the UCP API to set node labels. 
https://docs.docker.com/datacenter/ucp/2.2/reference/api/#!/Node/NodeList
https://docs.docker.com/datacenter/ucp/2.2/reference/api/#!/Node/NodeUpdate
