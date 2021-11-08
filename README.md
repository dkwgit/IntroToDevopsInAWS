# Getting going with DevOps against AWS

## Setup

1. [Setup an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
   - register it to YOURGMAIL+mainAWSAccount@gmail.com
1. [Get Visual Studio Code](https://code.visualstudio.com)
1. [Install the AWS CLI]( https://awscli.amazonaws.com/AWSCLIV2.msi)
1. Install the AWS Extensions:
    - AWS Toolkit
    - AWS CLI Configure
1. [Console login](https://aws.amazon.com/console)
1. Familiarizing yourself
    - try creating a programmatic IAM user with a an access key and secret
    - put those in your AWS CLI credentials file %USERPROFILE%/.aws (after installing aws CLI)
      - The command palette in VSC `Control-Shift-P` will have a AWS credential file open command from the 'AWS CLI Configure' extension, which is super helpful for entering credentials

Example (change to **YOUR values** for the programmatic IAM user)
>[default]
>
>aws_access_key_id=KEYVALUE
>
>aws_secret_access_key=SECRETVALUE
>
>region=us-east-1

- try creating a bucket using an AWS cli command `aws s3 mb s3://someuniquestring-sample-bucket-for-tim` (msut use a different bucket name)
- You can also try scripting out something in Powershell with a saved powershell script (Add-Bucket.ps1):
  
```Powershell
function Add-Bucket
{
    param(
      [Parameter(Mandatory=$true)][string]$BucketName
    )

    aws s3 mb "s3://$BucketName"
}
```

Invoke above via following in powershell terminal (which you can get via `Control-Shift-Backtick`)

```Powershell
. .\Add-Bucket.ps1

$newBucket = "someuniquestring-another-bucket-example"

Add-Bucket -BucketName $newBucket
```

## Working in CloudFormation

See Notes for two helpful extensions
If you have CloudFormation extension, you can do `Control-Shift-P` for command palette in VSC and then type CloudFormation, you should see a command named "AWS: Create New CloudFormation Template"
This gives you a barebones starting layout. Save that file with the following contens, as, for example, SampleCloudFormationTemplate.yaml.

```yaml
AWSTemplateFormatVersion: '2010-09-09'

Description: Sample CF template

Resources:
  MyBucket:
    Type: 'AWS::S3::Bucket'
```

Here is a powershell script that will copy a CloudFormation template, specified via $FileName to a bucket, then create as stack in CloudFormation. (Deloy-CFStack.ps1)

```Powershell
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
```

Invoke above via following in powershell terminal (which you can get via `Control-Shift-Backtick`)

```Powershell
. .\Deploy-CFStack.ps1

Deploy-CFStack -BucketName "a-unique-bucketname-xyz467" -FileName SampleCloudFormationTemplate.yaml -StackName "MyFirstStack"
```

## Notes

- If not installed in VSC by default, you will want the Powershell extension!
- Linters are plugins that find problems in language sytax
- I have the CloudFormation (by aws-scripting-guy) and CloudFormation Linter (kdddejong) extensions installed in VSC. Very helpful.
- [Sample CloudFormation templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html)
- [CloudFormation user guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
- [Sub-section of the CF user guide with all the resource types](  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)
- [Helpful Guide to Markdown syntax](https://www.markdownguide.org/basic-syntax/)
