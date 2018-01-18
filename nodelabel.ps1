$config = Get-Content .\test.json -raw | ConvertFrom-Json
$config.gettype()
$config | add-member -Name ooh -value ("Foo=Bar") -MemberType NoteProperty
$config | add-member -Name Labels -value ("com.microsoft.windows=myver") -MemberType NoteProperty
$config | add-member -Name Labels -value ("{label=com.microsoft.windows=myver}") -MemberType NoteProperty
$config | add-member -Name Labels2 -value ("{label=com.microsoft.windows=myver}") -MemberType NoteProperty
$config | ConvertTo-Json > isthisit.txt
