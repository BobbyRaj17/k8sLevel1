# k8sLevel1
Kubernetes setup &amp; Automation - Level 1

#Tasks
> Create kubernetes cluster on gcp

## Prerequisites
Your system needs the `gcloud setup` ,`helm` & `terraform`:
- [gcloud setup ](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform)
- [Terraform installation](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [gcloud cli](https://cloud.google.com/pubsub/docs/quickstart-cli)
- [gcloud create project](https://cloud.google.com/sdk/gcloud/reference/projects/create)
- [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [helm installation](https://helm.sh/docs/using_helm/)
- [gcloud container clusters get-credentials](https://cloud.google.com/sdk/gcloud/reference/container/clusters/get-credentials)

### 1. Steps to create Kubernetes cluster on GCP
Considering gcloud setup is done as mentioned in prerequisite, we can spin up the cluster using gcloud cli

```bash
    gcloud beta container --project "bobtestproject" clusters create "mstakx" --zone "asia-south1-c" --machine-type "custom-1-2048"  --disk-size "120" " --num-nodes "1" 
```

Alternative:
clone the repository - git clone https://github.com/BobbyRaj17/k8sLevel1.git
```bash
  cd gke/
  terraform init
  terraform plan -out=plan
  terraform apply plan
  ```
  
 #### Notes
 Please specify the project name under `gke/main.tf` & `gke/variables.tf` by default `bobtestproject` is provided
 similarly also select the appropriate zone, region, credentials & machine type in the above mentioned file that suits your requirement
 
 ### 2. install nginx ingress controller on the cluster
 
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

 In the output under RESOURCES, you should see the following:
 
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
 
### 3. create namespaces staging & production
 
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
  
 ### 4. install `guest-book` application on both the namespaces 
 
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
 `type: LoadBalancer`
```bash
    #Deployment guestbook on staging
    kubectl create -f guestbook/all-in-one/guestbook-all-in-one.yaml -n staging
    #Deployment guestbook on production
    kubectl create -f guestbook/all-in-one/guestbook-all-in-one.yaml -n production
```
  Helm charts are also avilable for guestbook application easily in github or we can create one for the above code which will simplify the above deployment

### 5. Expose staging application on hostname staging-guestbook.mstakx.io
```bash
    kubectl create -f guestbook/ingress-staging.yaml -n staging
```
 
### 6. Expose production application on hostname guestbook.mstakx.io
```bash
    kubectl create -f guestbook/ingress-production.yaml -n production
```
 
### 7 & 8. Script to demonstrate pods scaling up & down 

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
please refer the `PENDING` page for more detail reg. load testing and Horizontal pod autoscaler
 
Note: If you are also seeing <unknown> here, then this means that the resource limits are not set.
In such a scenario, the HPA won't work. Even if the CPU Utilization goes above threshold or more, new pods will not be created. To fix this we need to set the resource requests.

### 9. write a wrapper script 
```bash
    sh wrapper_script.sh
```

• What was the node size chosen for the Kubernetes nodes? And why?

```text
    Considering the task in hand of hosting guestbook application, I will choose a worker node having 1 cpu & 2 gb memory
    combing all the pods resources i.e. 5 pods in total and each  taking 100m cpu & 100mi memory will still be within the limits
```
> Note: if you are unsure about the workload then we can use autoscale cluster to save cost - [cluster autosacle](https://cloud.google.com/kubernetes-engine/docs/concepts/cluster-autoscaler)

• What method was chosen to install the demo application and ingress controller on the cluster, justify the method used.

```text
    I prefer helm to install the ingress as this is straight forward & also it take care of all the dependencies
```

• What would be your chosen solution to monitor the application on the cluster and why?

```text
    I prefer prometheus/grafana for monitoring & ELK for log aggregator and also would integrate the cluster with prometheus alert manager
```

• What additional components / plugins would you install on the cluster to manage it better?

```text
    I will setup  `cluster auto-scale` to manage node dynamically, `addon-resizer`  for vertically scaling  the dependent container up and down
```