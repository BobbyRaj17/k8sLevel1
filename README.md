# k8sLevel1
Kubernetes setup &amp; Automation - Level 1

#Tasks
> Create kubernetes cluster on gcp

## Prerequisites
Your system needs the `gcloud setup` , as well as `terraform`:
- [gcloud setup ](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform)
- [Terraform installation](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [gcloud cli](https://cloud.google.com/pubsub/docs/quickstart-cli)
- [gcloud create project](https://cloud.google.com/sdk/gcloud/reference/projects/create)
- [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm installation](https://helm.sh/docs/using_helm/)
- [gcloud container clusters get-credentials](https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials)

###Steps to create Kubernetes cluster on GCP
clone the repository
```bash
  cd gke/
  terraform init
  terraform plan -out=plan
  terraform apply plan
  ```
  
 #### Notes
 Please specify the project name under `gke/main.tf` & `gke/variables.tf` by default `bobtestproject` is provided
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
  
  Alternatively we can also create a cluster gcloud cli as shown below:
  ```bash
   gcloud container clusters create test-cluster --num-nodes=2 --project=bobtestproject --zone us-central1-a
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
 
 > create namespaces staging & production
 
 once the `gcloud container clusters get-credentials` setup is completed as mentioned in prerequisite we can use `kubectl` command to create k8s resources
 Using the kubectl &  `namespace-creation.yaml` available in the root directory of the repo we can create multiple namespaces.
  ```bash
  kube create -f namespace-creation.yaml
  ```
 You should see the following:
  
 ```
  namespace "staging" created
  namespace "production" created
 ``` 
  
 > install `guest-book` application on both the namespaces 
 
 Download the configuration files 
 The config files for this is available in kubernetes repo -> https://github.com/kubernetes/kubernetes/tree/release-1.10/examples/guestbook
 
 To deploy and run the guestbook application on GKE, we must:
 1. Set up a Redis master
 2. Set up Redis workers
 3. Set up the guestbook web frontend
 
 Using the below command we can switch the namespaces between production and staging & can deploy the guestbook application to both the namespaces
 ```bash
  kubectl config set-context $(kubectl config current-context) --namespace=<insert-namespace-name-here>
  # Validate it
  kubectl config view | grep namespace:
 ```
 Deployment steps using `kubectl`
 To create the Service, first, uncomment the following line in the frontend-service.yaml file:
 ``type: LoadBalancer``
 ```bash
  cd guestbook/
  kubectl create -f redis-master-deployment.yaml
  kubectl create -f redis-master-service.yaml
  kubectl create -f redis-slave-deployment.yaml
  kubectl create -f redis-slave-service.yaml
  kubectl create -f frontend-deployment.yaml
  kubectl create -f frontend-service.yaml
  ```
  Helm charts are also avilable for guestbook application easily in github or we can create one for the above code which will simplify the above deployment

 > Expose staging application on hostname staging-guestbook.mstakx.io
 `PENDING`
 
 > Expose production application on hostname guestbook.mstakx.io
 `PENDING`
 
 > Script to demonstrate pods scaling up & down 

Create `Horizontal pod auto-scaler` using `kubectl`

 ```bash
    kubectl create -f autoscale.yaml -n staging
    kubectl create -f autoscale.yaml -n production
 ```

The below script requires four argument & to produce some load on the service we will use, a tool called wrk
```bash
 /loadTesting.sh <no of threads> <no of connection> <Total time> <url to test>
```

e.g. ./loadTesting.sh "200" "200" "15m" "http://35.222.72.128:3000/"
please refer the the page for more detail reg. load testing and Horizontal pod autoscaler
 
Note: If you are also seeing <unknown> here, then this means that the resource limits are not set.
In such a scenario, the HPA won't work. Even if the CPU Utilization goes above threshold or more, new pods will not be created. To fix this we need to set the resource requests.
