# nodelabel.ps1
# adds an engine label for the version of Windows in use

$configfile = "c:\programdata\docker\config\daemon.json"
$labelroot = "docker.engine.winver"
$winver = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | % {"{0}.{1}.{2}.{3}" -f $_.CurrentMajorVersionNumber,$_.CurrentMinorVersionNumber,$_.CurrentBuildNumber,$_.UBR}
$label = @($labelroot + "=" + $winver)                                                                        

$data = Get-Content $configfile | ConvertFrom-Json                                                              
$data | add-member -type NoteProperty -Name "labels" -Value $label                                              
$data | ConvertTo-Json | Out-File $configfile -Encoding ASCII
