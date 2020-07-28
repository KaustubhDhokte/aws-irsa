#!/bin/bash

AWS_ROOT_ACCOUNT_ID=$1
timestamp="$(date +%s)"
NEW_USER_NAME="NIU"
NEW_ROLE_NAME="NIR"
SERVICE_ACCOUNT_NAME="triliobkpadmin"
CERTIFICATE_PERIOD=365
POD_IDENTITY_SERVICE_NAME=pod-identity-webhook
POD_IDENTITY_SECRET_NAME=pod-identity-webhook
POD_IDENTITY_SERVICE_NAMESPACE=$2
SCRIPTS="deploy_$2"
PCNAME="triliovault"

rm -rf certs
mkdir -p certs

Printf "\n*****************************************************************************************************************"

Printf "\nCreating certificates...\n"

#Create certificate for pod-identity-webhook
openssl req \
        -x509 \
        -newkey rsa:2048 \
        -keyout certs/tls.key \
        -out certs/tls.crt \
        -days $CERTIFICATE_PERIOD -nodes -subj "/CN=$POD_IDENTITY_SERVICE_NAME.$POD_IDENTITY_SERVICE_NAMESPACE.svc"

#Create secret for pod-identity-webhook to get certificate
kubectl create secret generic $POD_IDENTITY_SECRET_NAME \
        --from-file=./certs/tls.crt \
        --from-file=./certs/tls.key \
        --namespace=$POD_IDENTITY_SERVICE_NAMESPACE

Printf "\nCertificates created...\n"

Printf "\n*****************************************************************************************************************"

Printf "\nCreating user... \n"

aws iam create-user --user-name $NEW_USER_NAME

Printf "\nUser created... \n"

Printf "\n*****************************************************************************************************************"

Printf "\nCreating role... \n"

ROLE_AWS_POLICY_USER_ARN="arn:aws:iam::$AWS_ROOT_ACCOUNT_ID:user/$NEW_USER_NAME"

cat > irsa-trust-policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "$ROLE_AWS_POLICY_USER_ARN"
      },
      "Action": "sts:AssumeRole",
      "Condition": {}
    }
  ]
}
EOF

sleep 10

aws iam create-role --role-name $NEW_ROLE_NAME --assume-role-policy-document file://irsa-trust-policy.json

Printf "\nRole created...\n"

Printf "\n*****************************************************************************************************************"

Printf "\nAttaching S3 Policy...\n"

sleep 10

aws iam attach-role-policy --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess --role-name $NEW_ROLE_NAME

Printf "\nPolicy updated...\n"

Printf "\n*****************************************************************************************************************"

Printf "\nInstalling the hook...\n"

echo $SCRIPTS

cat $SCRIPTS/mutatingwebhook.yaml | ./webhook-patch-ca-bundle.sh > $SCRIPTS/mutatingwebhook-ca-bundle.yaml

kubectl apply -f $SCRIPTS/auth.yaml
kubectl apply -f $SCRIPTS/deployment.yaml
kubectl apply -f $SCRIPTS/service.yaml
kubectl apply -f $SCRIPTS/mutatingwebhook-ca-bundle.yaml

Printf "\nhook installed...\n"

Printf "\n*****************************************************************************************************************"

Printf "\nCreating and Annotating service account with the role ... \n"

ROLE_ARN=$(aws iam get-role --role-name $NEW_ROLE_NAME --query Role.Arn --output text)

kubectl create sa $SERVICE_ACCOUNT_NAME

kubectl annotate sa $SERVICE_ACCOUNT_NAME eks.amazonaws.com/role-arn=$ROLE_ARN

kubectl get sa $SERVICE_ACCOUNT_NAME -o yaml

Printf "\n*****************************************************************************************************************"

Printf "\nBOTO3 POD after installing hook... \n"

sed -e "s/PCNAME/${PCNAME}/g" kaustubhboto3.yaml.template > kaustubhboto3before.yaml

sed -e "s/SANAME/$SERVICE_ACCOUNT_NAME/g" kaustubhboto3before.yaml > kaustubhboto3.yaml

kubectl create -f kaustubhboto3.yaml

kubectl get pod ${PCNAME} -o yaml

Printf "\n*****************************************************************************************************************\n"