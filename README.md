# Windows image compatibility
Samples and scripts for the Windows image compatibility runbook

## Reducing the overhead of maintaining custom labels on each node
The Windows Server run book is predicated on the use of labels that contain the Windows version running on each node, and service constraints that reference those labels to bind a service using images built on a given Windows version to hosts running the same Windows version.

Note: For security reasons the ```docker node update``` command can only be run on Swarm masters, so it can't be used to set node labels based on worker settings that must be determined remotely.

Here are two alternate methods to automate setting labels for worker nodes containing their Windows version:

### Powershell script to add engine label
Docker engine labels are created with entries in the Docker [daemon configuration file](https://docs.docker.com/engine/reference/commandline/dockerd/#daemon-configuration-file). ```enginelabel.ps1``` creates an engine label named ```engine.labels.windowsversion``` with a value of the Windows version in use in the form of ```major.minor.build.revision```.

The script must be run on the Windows node and is intended for use as a step the node provisioning process.

### UCP API to set node labels
The Universal Control Plane (UCP) API allows setting node labels equivalent to the ```docker node label``` CLI command. ```nodelabel.py``` is a Python script that takes a Windows version as a parameter and creates a ```com.docker.ucp.node.windowsversion``` node label with the specified value on all Windows nodes in the cluster where it does not exist.

The script can be run anywhere a client bundle has been sourced, and is intended as a step in provisioning new nodes in a cluster. This approach assumes all services in the cluster have constraints pinning them to a specific ```com.docker.ucp.node.windowsversion``` value, allowing new nodes to be added to the cluster without being incorrectly assigned tasks prior to having their ```com.docker.ucp.node.windowsversion``` label set.

#### UCP API reference
https://docs.docker.com/datacenter/ucp/2.2/reference/api/#!/Node/NodeList
https://docs.docker.com/datacenter/ucp/2.2/reference/api/#!/Node/NodeUpdate

## Working with 3rd party Windows images
Microsoft provides tags for each patch release of Windows Server base images, so creating apps and services directly from a specific version of those base images only requires explicitly referencing the appropriate tag in a ```dockerfile```, such as:

```FROM microsoft/windowsservercore:10.0.14393.2068```

Microsoft also provides a general tag that always provides the latest version of the image. For Windows Server 2016 this is the ```ltsc2016``` tag. When specifying that tag, or no tag, the exact version of the base image returned is not predictable as new patch level images become available over time.

Many 3rd party images derived from Windows Server base images, such as ```library\python```, specify the ```ltsc2016``` tag or no tag at all. In those cases, here are two methods to ensure a predictable version of the Windows base images is used:

### Fork the dockerfile
With some images it may be possible to create a copy of the image's ```dockerfile``` and replace it's general tag reference to the Windows base image with an explicit one, pinning it to the specified version.

### Capturing a specific version of the image
[Stefan Scherer's](@stefscherer) WinSpector tool can be used to determine the Windows base image and patch level of any image:

```
$ docker run --rm stefanscherer/winspector library/python:3.6.4-windowsservercore-ltsc2016
Retrieving information about source image library/python:3.6.4-windowsservercore-ltsc2016
Retrieving information about source image library/python:sha256:443d89ead05636e9050abc717896c391059737671d38643283178c4efe597e05
Image name: library/python
Tag: sha256:443d89ead05636e9050abc717896c391059737671d38643283178c4efe597e05
Number of layers: 9
Schema version: 2
Architecture: amd64
Created: 2018-02-14T17:39:42.4157502Z with Docker 17.06.1-ee-2 on windows 10.0.14393.2068
Sizes of layers:
  sha256:3889bb8d808bbae6fa5a33e07093e65c31371bcf9e4c38c21be6b9af52ad1548 - 4069985900 byte
  sha256:cfb27c9ba25f60372361ea8779c927f066c385b6339e29fda5c739feb3163686 - 1308156033 byte
  sha256:8611b5f5c0763027c0888bf4535b5f42b6c1a8f72d264baea9e7362a4907c2c3 - 1193 byte
  sha256:e1203aa2a18f00a91fa56afedfc4eecc2d7482728d600ae81f9517acb1ee8836 - 1194 byte
  sha256:8656734711892c38300eb858a50ed9a1dd90ebc9cc7ff82baa553b991ac984a0 - 1201 byte
  sha256:79cc9f2374452a6a295c39b171598bf36e98973ffbeb3f79cd77bcb09755d04d - 51979245 byte
  sha256:aa566deac2370e022a06e4c067679c54b68062169543acbafd7d87984004cec9 - 1200 byte
  sha256:1d01ccb7cae406f9450d36815b807aecc5cb9cfec343acc425d83646a59367b1 - 9366873 byte
  sha256:9323b7730b97406e78865eb4e336049104c1cd72311b4138071d07c46aaee399 - 1177 byte
Total size (including Windows base layers): 5439494016 byte
Application size (w/o Windows base layers): 61352083 byte
Windows base image used:
  microsoft/windowsservercore:10.0.14393.447 full
  microsoft/windowsservercore:10.0.14393.2068 update
History:
   Apply image 10.0.14393.0
   Install update 10.0.14393.2068
   SHELL [powershell -Command $ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';]
   ENV PYTHON_VERSION=3.6.4
   ENV PYTHON_RELEASE=3.6.4
<snip>
```

In this example the patch-level version of ```microsoft/windowsservercore``` in the image is ```10.0.14393.2068```.

The version of the base image can used to create an explicit tag for the 3rd party image including the version of the base images it's based on, such as ```3.6.4-windowsservercore-10.0.14393.2068```. That tag can in turn be referenced in apps or services deriving from the 3rd party image.

## dockerfile arguments

