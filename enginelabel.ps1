# enginelabel.ps1
# adds an engine label into daemon.json for the Windows version in use
#
# covers the following cases
#   1 - no daemon.json file
#   2 - daemon.json file with other settings
#   3 - daemon.json file with other label values
#   4 - daemon.json file containing the label to be added (no change)

$configroot = $Env:PROGRAMDATA
$configfile = $configroot + "\docker\config\daemon.json"
$labelroot = "engine.labels.windowsversion"
$winver = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" | % {"{0}.{1}.{2}.{3}" -f $_.CurrentMajorVersionNumber,$_.CurrentMinorVersionNumber,$_.CurrentBuildNumber,$_.UBR}
$label = @($labelroot + "=" + $winver) 

# If configfile exists get it's content, otherwise create a new object
if ($configfile | Test-Path) {
   $data = Get-Content $configfile | ConvertFrom-Json
} else {
   $data = New-Object PsObject
}

# Check for existing labels and add if not already present
if ($data.labels -ne $nul){ 
   if ($data.labels -contains $label){
       # label already exists, done
       exit
       } else {
          $data.labels += $label
       }
  } else {
    $data | add-member -type NoteProperty -Name "labels" -Value $label
    }

# Update configfile
$data | ConvertTo-Json | Out-File $configfile -Encoding ASCII
