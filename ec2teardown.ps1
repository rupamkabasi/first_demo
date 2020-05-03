$build_number= $env:BUILD_NUMBER
write-host $build_number
$build_tag= $env:BUILD_TAG
write-host $build_tag
write-host removing instance $build_tag
Set-AWSCredential -AccessKey AKIAZN2TGWISBQXQXD33 -SecretKey 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 -StoreAs user1
Initialize-AWSDefaults -ProfileName user1 -Region ap-southeast-2
$instanceID= (Get-EC2Tag -Filter @{Name="tag:Name";Value="$build_tag"} | Select-Object ResourceId).ResourceId
Remove-EC2Instance -InstanceId $instanceID -Force 
write-host code changed