function Deploy-CFStack
{
    param(
      [Parameter(Mandatory=$true)][string]$BucketName,
      [Parameter(Mandatory=$true)][string]$FileName,
      [Parameter(Mandatory=$true)][string]$StackName
    )

    aws s3 cp $FileName "s3://$BucketName"
    aws cloudformation create-stack --stack-name $StackName --template-url "http://$BucketName.s3.us-east-1.amazonaws.com/$FileName"
}