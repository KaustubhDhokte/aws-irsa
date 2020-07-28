# aws-irsa
Automating the steps to deploy AWS IAM identity webhook to work with IAM roles mapped to IAM users


Make sure you have run the clean up script of previous attempt before running configurator

Run the configurator

./configure <aws_root_account_id> <kubernetes_namespace>

e.g. ./configure abcd kube-system


Run the cleanup

./cleanup <aws_root_account_id> <kubernetes_namespace>

e.g. ./cleanup abcd kube-system
