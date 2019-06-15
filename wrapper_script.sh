#!/usr/bin/env bash


#Create a GKE cluster in asia-south1-c Region with 1 node and 20GB Disk Size.
gcloud beta container --project "bobtestproject" clusters create "mstakx" --zone "asia-south1-c" --machine-type "custom-1-2048"  --disk-size "20" --num-nodes "1"

#Install nginx ingress controller using helm

helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true

#Create namespaces called staging and production
git clone https://github.com/BobbyRaj17/k8sLevel1.git; cd k8sLevel1
kubectl create -f namespace-creation.yaml

# Deploy guestbook application on staging & production
for namespace in staging production
do
    kubectl create -f guestbook/ingress-staging.yaml -n ${namespace}
done

#Loadtesting the frontend deployment using wrk
sh loadTesting.sh "200" "200" "15m" "http://35.239.75.46/"