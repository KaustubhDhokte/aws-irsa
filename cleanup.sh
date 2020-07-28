#!/bin/bash

AWS_ROOT_ACCOUNT_ID=$1
timestamp="$(date +%s)"
NEW_USER_NAME="NIU"
NEW_ROLE_NAME="NIR"
SERVICE_ACCOUNT_NAME="triliobkpadminksmeet"
CERTIFICATE_PERIOD=365
POD_IDENTITY_SERVICE_NAME=pod-identity-webhook
POD_IDENTITY_SECRET_NAME=pod-identity-webhook
POD_IDENTITY_SERVICE_NAMESPACE=$2
SCRIPTS="deploy_$2"

kubectl -n $POD_IDENTITY_SERVICE_NAMESPACE delete -f kaustubhboto3.yaml

kubectl -n $POD_IDENTITY_SERVICE_NAMESPACE delete sa $SERVICE_ACCOUNT_NAME

# kubectl delete -f kaustubhboto3.yaml

# kubectl delete sa $SERVICE_ACCOUNT_NAME

kubectl delete -f $SCRIPTS/mutatingwebhook-ca-bundle.yaml
kubectl delete -f $SCRIPTS/service.yaml
kubectl delete -f $SCRIPTS/deployment.yaml
kubectl delete -f $SCRIPTS/auth.yaml
kubectl -n $POD_IDENTITY_SERVICE_NAMESPACE delete secret pod-identity-webhook

aws iam detach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name $NEW_ROLE_NAME

sleep 5

aws iam delete-role --role-name $NEW_ROLE_NAME

sleep 5

aws iam delete-user --user-name $NEW_USER_NAME
