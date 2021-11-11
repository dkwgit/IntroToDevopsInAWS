# Getting going with DevOps against AWS

These instructions are meant to get you started with basic tools and provisioning approaches against an AWS account. The goal is to equip you to provision AWS infrastructure in a scripted fashion. The tools and approaches are only some of many ways of doing this kind of thing, but are definitely mainstream choices that will equip you well for work in a variety of contexts.

## Table of Contents

- Getting going with DevOps against AWS
  - Table of Contents
  - Concepts
    - Infrastructure as code
    - Declarative infrastructure as code tools
    - Concepts not yet being dealt with
      - How to put automation in a formal CI/CD context
  - Setup
  - Familiarizing yourself with running AWS CLI commands against an account
  - Working in CloudFormation
  - Cleanup
    - What needs clean up
    - How to clean up
  - Notes

## Concepts

Currently, this intro will just get you going with tools and basic setup.  The real DevOps concepts to be dealt with don't get a lot of treatment (yet). However, those concepts are the most important. (But it's also hard to learn about them if you don't have some tools ready and places to provision infrastructure to).

Here is the main concept this is about:

### Infrastructure as code

The idea is that any infrastructure you deploy ought to be deployable via automation, so that it is

1. Always deployed programmatically, not via a user haphazardly clicking in the console.
1. Deployed in a controlled fashion, from source code artifacts, under repeatable, well known governance. This intro does not deal with governance, but for work in an enterprise context, governance is perhaps the most vital element of DevOps.

### Declarative infrastructure as code tools

Usually, a declarative provisioning tool, such as AWS's CloudFormation (or, as an example of a cloud agnostic tool, Terraform) is involved. However, the simplest form of infrastructure as code might just provision infrastructure via a scripting approach, which is at least automated and repeatable. There are distinct benefits to a provisioning tool, though. Such a tool can:

1. track dependencies between infrastructure resources, and protect dependent resources by refusing to delete other resources (which the dependent resources need).
1. document the state of resources more fully (the tool itself is a place to inspect the intended state)
1. detect drift (has a resource changed since it was provisioned?)
1. provide a careful update path when a resource is changing. The update path can rollback to a known good state, if the tool detects that an update will fail.
1. provide some reusable modularization for frequent provisioning tasks (not a CloudFormation strength)

### Concepts not yet being dealt with

#### How to put automation in a formal CI/CD context

## Setup

These are Windows centric instructions.

1. Install Powershell
   - [For Windows, simplest to use the MSI package](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows)
1. [Setup an AWS account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)
   - register it to YOURGMAIL+mainAWSAccount@gmail.com

   The suffix after '+', 'mainAWSAccount' lets you spin off an apparently new email address everytime you need to. Since every AWS account you create needs a unique address, this lets you use one email address and still have multiple email accounts in AWS (you'll want to do this as you get more advanced in AWS). Gmail will still deliver to YOURGMAIL@gmail.com, it ignores the '+suffix'. I don't know if other email providers do this. Use whatever suffix scheme suits you.
1. [Get Visual Studio Code](https://code.visualstudio.com)
1. Also install command line Git (VSC will come with Git support, but you want to have command line git, too.
   - [For Windows](https://gitforwindows.org/)
  
  This may ask you for a lot of choices to make. You can start by accepting defaults. Laster, you can change settings, if you want to or reinstall. (Todo: give some better helps on these choices!)
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
- you'll want to familiarize yourself with [AWS CLI credentials and config files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html).
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

See Notes for two helpful extensions in VSC.

If you have installed recommended extensions, you can do `Control-Shift-P` for command palette in VSC and then type CloudFormation, you should see a command named "AWS: Create New CloudFormation Template". This gives you a barebones starting layout. Save that file with the following contens, as, for example, SampleCloudFormationTemplate.yaml.

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
    aws CloudFormation create-stack --stack-name $StackName --template-url "http://$BucketName.s3.us-east-1.amazonaws.com/$FileName"
}
```

Invoke above via following in powershell terminal (which you can get via `Control-Shift-Backtick`)

```Powershell
. .\Deploy-CFStack.ps1

Deploy-CFStack -BucketName "a-unique-bucketname-xyz467" -FileName SampleCloudFormationTemplate.yaml -StackName "MyFirstStack"
```

- Go to CloudFormation in the console and view the stack that you just created.
- In CloudFormation, check out the resources of the stack. Your bucket should be there as a resource.
- Go look in S3 in the console and see your bucket that way, as well.

## Cleanup

### What needs clean up

- Delete your CloudFormation stack when done
- Delete any S3 buckets you do not want to keep that were not under CloudFormation control

### How to clean up

This should really be done in scripts!! Delete the CloudFormation stack from CF service via script. What aws cli command is this? Delete extraneous S3 buckets via script.  What CLI commands?

## Notes

- If not installed in VSC by default, you will want the Powershell extension!
- Linters are plugins that find problems in language sytax in files for a given language.
- I have the CloudFormation (by aws-scripting-guy) and CloudFormation Linter (kdddejong) extensions installed in VSC. Very helpful.
- [Sample CloudFormation templates](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/sample-templates-services-us-west-2.html)
- [CloudFormation user guide](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/Welcome.html)
- [Sub-section of the CF user guide with all the resource types](  https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html)
- [Helpful Guide to Markdown syntax](https://www.markdownguide.org/basic-syntax/)
