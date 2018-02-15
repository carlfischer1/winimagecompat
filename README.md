# Windows image compatibility
Testing, samples, and scripts for Windows image compatibility runbook

## Reducing the overhead of maintaining custom labels on each node
The Windows Server run book is predicated on the use of labels that contain the Windows version running on each node, and service constraints that reference those labels to bind a service using images built on a given Windows version to hosts running the same Windows version.

Note: For security reasons the ```docker node update``` command can only be run on Swarm masters, so it can't be used to set node labels based on worker settings that must be determined remotely.

Here are two alternate methods to automate setting labels for worker nodes containing their Windows version:

### Powershell script to add engine label
Docker engine labels are created through entries in the Docker [daemon configuration file](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file). ```enginelabel.ps1``` creates an engine label named ```engine.labels.windowsversion``` with a value of the Windows version in use in the form of ```major.minor.build.revision```.

The script must be run on the Windows node and is intended for use as a step the node provisioning process.

### UCP API to set node labels
Another option is to use the UCP API to set node labels. 
https://docs.docker.com/datacenter/ucp/2.2/reference/api/#!/Node/NodeList
https://docs.docker.com/datacenter/ucp/2.2/reference/api/#!/Node/NodeUpdate


### Also investigated

### Going forward, Kubernetes labels

#### Using Linux Powershell to remotely gather Windows version 
On Ubuntu 16.10 UCP master:

1 - Install Powershell for Linux
```
curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list | sudo tee /etc/apt/sources.list.d/microsoft.list
sudo apt-get update
sudo apt-get install -y powershell
```

2 - Install Powershell Linux -> Windows remoting support
```
apt-get install omi
apt-get install omi-psrp-server
```

```
pwsh
```

References
* https://blogs.msdn.microsoft.com/powershell/2017/02/01/installing-latest-powershell-core-6-0-release-on-linux-just-got-easier/
* https://github.com/Microsoft/omi
* https://github.com/PowerShell/psl-omi-provider

# Reference
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
