---
layout: post
title: Decrypt AWS Instance Credentials - Powershell & AWS CLI
---

Fairly simple script to grab AWS EC2 Instance defualt password using Powershell & AWS CLI. You must update the script to point to your locally stored Private Key files. 

Allows for searching for instances, or simply provide the full instance name's password you wish to decrypt.

--- Start Sctipt Block ---

<pre>
<code>
#DM AWS Credential Decrypter Script

# Get AWS Instance Passowrd
Import-Module AWSPowerShell

#Configure Region
Get-AWSRegion | out-host
$region = Read-Host "Type the Region you want to work in (e.g. us-east-1)"
$keypath = <PATH TO KEYS HERE>

#Set AWS KeyFile based on Region
if ($region -eq "us-west-2"){
    $pathtokey = "$keypath\name.pem"
}
if ($region -eq "us-east-1"){
    $pathtokey = "$keypath\name.pem"
}
if ($region -eq "ap-northeast-1"){
    $pathtokey = "$keypath\name.pem"
}
if ($region -eq "sa-east-1"){
    $pathtokey = "$keypath\name.pem"
}
if ($region -eq "eu-west-1"){
    $pathtokey = "$keypath\name.pem"
}
if ($region -eq "eu-central-1"){
    $pathtokey = "$keypath\name.pem"
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
<code>
<pre>

--- End Script Block ---
