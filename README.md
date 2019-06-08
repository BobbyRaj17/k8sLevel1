# k8sLevel1
Kubernetes setup &amp; Automation - Level 1

#Tasks
> Create kubernetes cluster on gcp

## Prerequisites
Your system needs the `gcloud setup` , as well as `terraform`:
- [gcloud setup ](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform)
- [Terraform installation](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [gcloud cli](https://cloud.google.com/pubsub/docs/quickstart-cli)
- [gcloud projects create](https://cloud.google.com/sdk/gcloud/reference/projects/create)
- [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm installation](https://helm.sh/docs/using_helm/)

###Steps to create Kubernetes cluster on GCP
clone the repository
```bash
  cd gke/
  terraform init
  terraform plan -out=plan
  terraform apply plan
  ```
  
 #### Notes
 please specify the project name under `gke/main.tf` & `gke/variables.tf` by default `bobtestproject` is provided
 similarly also select the appropriate zone, region, credentials & machine type in the above mentioned file that suits your requirement
 
 >  install nginx ingress controller on the cluster
 
 we can leverage the helm for this as helm make it very easy and couple of commands to setup `nginx ingress controller` 
 
 If your Kubernetes cluster has RBAC enabled, from the Cloud Shell, deploy an NGINX controller Deployment and Service by running the following command:
 ```bash
  helm install --name nginx-ingress stable/nginx-ingress --set rbac.create=true --set controller.publishService.enabled=true
  ```
 
 Deploy NGINX Ingress Controller with RBAC disabled
 If your Kubernetes cluster has RBAC disabled, from the Cloud Shell, deploy an NGINX controller Deployment and Service by running the following command:
  ```bash
   helm install --name nginx-ingress stable/nginx-ingress
  ```

 In the ouput under RESOURCES, you should see the following:
 
 ``` bash
  ==> v1/Service
  NAME                           TYPE          CLUSTER-IP    EXTERNAL-IP  PORT(S)                     AGE
  nginx-ingress-controller       LoadBalancer  10.7.248.226  pending      80:30890/TCP,443:30258/TCP  1s
  nginx-ingress-default-backend  ClusterIP     10.7.245.75   none         80/TCP                      1s
  
 ```
 Wait a few moments while the GCP L4 Load Balancer gets deployed. Confirm that the nginx-ingress-controller Service has been deployed and that you have an external IP address associated with the service. Run the following command:
 
 ```bash
  kubectl get service nginx-ingress-controller
  ```
 
 You should see the following:
 
 ```bash
  NAME                       TYPE           CLUSTER-IP     EXTERNAL-IP      PORT(S)                      AGE
  nginx-ingress-controller   LoadBalancer   10.7.248.226   35.226.162.176   80:30890/TCP,443:30258/TCP   3m
  ```
  
 Notice the second service, nginx-ingress-default-backend. The default backend is a Service which handles all URL paths and hosts the NGINX controller doesn't understand (that is, all the requests that are not mapped with an Ingress Resource). The default backend exposes two URLs:
 
 * /healthz that returns 200
 * / that returns 404
 
 
 ```bash
 
 ```