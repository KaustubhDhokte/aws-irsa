# aws-irsa
Automating the steps to deploy AWS IAM identity webhook to work with IAM roles mapped to IAM users

Prerequisites:

This package assumes you have below libraries installed

1. AWS (tested with aws-cli/2.0.30 Python/3.7.4 Darwin/18.7.0 botocore/2.0.0dev34)
2. Kubectl (tested with client version v1.18.3, server version v1.16.8-eks-fd1ea7)

A running EKS setup in us-east-2 region.

AWS cli and kubectl configured to work with EKS setup.

Run the configurator

./configure <aws_root_account_id> <kubernetes_namespace>

e.g. ./configure abcd kube-system

What happens behind the scenes?
1. Create an IAM user
2. Create an IAM role mapped to above created IAM user and with Attached Full S3 Access Policy
3. Install Amazon-eks-identity-webhook in the namespace provided to the command
4. Create a service account in default namspace
5. Annotate the service account with the ROLE ARN created in step 2
6. Create a BOTO3 container pod with this service account


Run the cleanup

./cleanup <aws_root_account_id> <kubernetes_namespace>

e.g. ./cleanup abcd kube-system

(Note: Make sure you have run the clean up script of previous attempt before running configurator)