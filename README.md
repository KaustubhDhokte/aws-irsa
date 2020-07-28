# aws-irsa
Automating the steps to deploy AWS IAM identity webhook to work with IAM roles mapped to IAM users

Run the configurator

./configure <aws_root_account_id> <namespace>

e.g. ./configure abcd kube-system


Run the cleanup

./cleanup <aws_root_account_id> <namespace>

e.g. ./cleanup abcd kube-system
