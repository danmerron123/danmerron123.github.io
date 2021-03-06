#Dan's AWS Credential Decrypter Script

# Get AWS Instance Passowrd
Import-Module AWSPowerShell

#Configure Region
Get-AWSRegion | out-host
$region = Read-Host "Type the Region you want to work in (e.g. us-east-1)"
$keypath = <PATH TO KEYS HERE>

#Set AWS KeyFile based on Region
if ($region -eq "us-west-2"){
    $pathtokey = "$keypath\us-west-2.pem"
}
if ($region -eq "us-east-1"){
    $pathtokey = "$keypath\us-east-1.pem"
}
if ($region -eq "ap-northeast-1"){
    $pathtokey = "$keypath\AP-Northeast-1.pem"
}
if ($region -eq "sa-east-1"){
    $pathtokey = "$keypath\sa-east-1.pem"
}
if ($region -eq "eu-west-1"){
    $pathtokey = "$keypath\eu-west-1.pem"
}
if ($region -eq "eu-central-1"){
    $pathtokey = "$keypath\eu-central-1.pem"
}

Write-Host "Keyfile: $pathtokey" -foregroundcolor red
Set-DefaultAWSRegion -Region $region
$ListInstances = Read-host "Do you need to search for instance names? [y|n]"

if ($ListInstances -eq "y"){
    $SearchString = Read-host "Type part of Instance Name"
    Write-Host ""
    $ServerName = aws ec2 describe-instances --filters "Name=tag:Name,Values=$SearchString" "Name=instance-state-name,Values=running" --query 'Reservations[*].Instances[*].Tags[?Key==`Name`].Value[]' --output text --region $region
    $ServerName
}

if ($ServerName.count -eq 1){
$InstanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=$ServerName" "Name=instance-state-name,Values=running" --query 'Reservations[*].[Instances[*].InstanceId]' --output text --region $region
}
elseif($ServerName.count -ge 2){
#Get the Password
$ServerName = Read-host "What is the Instance name?"
$InstanceId = aws ec2 describe-instances --filters "Name=tag:Name,Values=$ServerName" "Name=instance-state-name,Values=running" --query 'Reservations[*].[Instances[*].InstanceId]' --output text --region $region
}

Clear

foreach ($IID in $InstanceID){
Write-Host "Decrypting password for $ServerName... " -foregroundcolor yellow
$password = aws ec2 get-password-data --instance-id $IID --query 'PasswordData' --priv-launch-key $pathtokey --output text --region $region
$password | clip
$password
Write-Host ""
}
Write-Host "Copied password to your Clipboard - You're welcome!" -ForegroundColor yellow
Write-Host ""
Read-Host "Press Enter to quit."