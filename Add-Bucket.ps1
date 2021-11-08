function Add-Bucket
{
    param(
      [Parameter(Mandatory=$true)][string]$BucketName
    )

    aws s3 mb "s3://$BucketName"
}