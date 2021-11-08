# Getting going with DevOps against AWS

## Setup

These are Windows centric instructions.

1. Install Powershell
   - [For Windows, simplest to use the MSI package](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
1. Install Git
   - [For Windows](https://gitforwindows.org/)
1. [Setup an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
   - register it to YOURGMAIL+mainAWSAccount@gmail.com
1. [Get Visual Studio Code](https://code.visualstudio.com)
1. [Install the AWS CLI]( https://awscli.amazonaws.com/AWSCLIV2.msi)
1. Install the AWS Extensions:
    - AWS Toolkit
    - AWS CLI Configure
1. [Console login](https://aws.amazon.com/console)
1. Clone this repo to your local system for some examples to work with

   - establish a folder %USERPROFILE%/repos. Go to %USERPROFILE% in windows explore. Make a folder 'repos'
   - open a powershell window `WindowsKey-Q` type 'Powershell'. Open Powershell.
   - type `cd "$($env:USERPROFILE)\repos"`
   - type `git clone https://github.com/dkwgit/IntroToDevopsInAWS.git`

1. Open Visual Studio Code to this newly downloaded project

- `cd IntroToDevopsInAWS`.  You should now be in c:\Users\YOURUSERNAME\repos\IntroToDevopsInAWS
- `code .` this opens the current folder in Visual Studio Code

## Familiarizing yourself with running AWS CLI commands against an account

- try creating a programmatic IAM user in your AWS account via the console, with a an access key and secret
- put those in your AWS CLI credentials file %USERPROFILE%/.aws (after installing aws CLI)
- the 'AWS CLI Configure' extension will open the credentials file for you:
  
  the command palette in VSC `Control-Shift-P` will have a AWS credential file open command from the 'AWS CLI Configure' extension, which is super helpful for entering credentials

  Example (change to **YOUR values** for the programmatic IAM user)
  >[default]
  >
  >aws_access_key_id=KEYVALUE
  >
  >aws_secret_access_key=SECRETVALUE
  >
  >region=us-east-1

- try creating a bucket using an AWS cli command `aws s3 mb s3://sample-uniquebucketname-qwerty-875` (**only an example must use a globally unique bucket name**)
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

  $newBucket = "sample-uniquebucketname-zxcvb-3874" # **Only an example must use a globally uniqe bucket name**

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

## Cleanup

- Delete your S3 buckets when done!

## Notes

- If not installed in VSC by default, you will want the Powershell extension!
- Linters are plugins that find problems in language sytax
- I have the CloudFormation (by aws-scripting-guy) and CloudFormation Linter (kdddejong) extensions installed in VSC. Very helpful.
- [Sample CloudFormation templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html)
- [CloudFormation user guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
- [Sub-section of the CF user guide with all the resource types](  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)
- [Helpful Guide to Markdown syntax](https://www.markdownguide.org/basic-syntax/)
