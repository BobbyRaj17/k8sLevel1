# k8sLevel1
Kubernetes setup &amp; Automation - Level 1


## Prerequisites
Your system needs the `gcloud setup` , as well as `terraform`:
- [gcloud setup ](https://cloud.google.com/community/tutorials/getting-started-on-gcp-with-terraform)
- [Terraform installation](https://learn.hashicorp.com/terraform/getting-started/install.html)

###Steps to create Kubernetes cluster on GCP
clone the repository
```bash
  cd gke/
  terraform init
  terraform plan -out=plan
  terraform apply plan
  ```
  
 ## Notes
 please specify the project name under `gke/main.tf` & `gke/variables.tf` by default `bobtestproject` is provided
 similarly also select the appropriate zone, region, credentials & machine type in the above mentioned file that suits your requirement
 
  