# Task - 2 Deploy on AWS with Terraform

## Initial design considerations

To simplify, I would put the frontend in S3 and the backend in an APIGW + ECS, or APIGW + Lambda (depending on traffic profile), but as I understand that your frontend in the future will be dynamic (not compatible with S3) and as well you want to test my skills in EKS as Aily uses it, I am going to create all infra in EKS.

## EKS solution

In this folder we have two terraform projects:

1. Network: where is defined VPC and Subnets (2xpublic, 2xprivate), IGW, NATGW.

2. EKS: Where the EKS cluster is created:
    1. Control plane in public subnets.
    2. Data plane (Nodegroup) in private subnets.
    3. Addons.
    4. IAM roles created (aws-auth).
    5. Access to the front/app just from the ALB. allowing port 80 only.
    6. HA using two AZ's where to spread the depolyment's PODs (The control plane is as well in HA).

First run in terraform the "network" plan and next the "EKS" plan with
````
terraform init
terraform plan
terraform apply
```
Notes
- I use different plans because at scale, when you have a lot of resources, terraform commands are getting slower and slower if you use just one plan. As well is a more clear to organize the projects and find resources by project. (Atlantis)[https://www.runatlantis.io/] is a good candidate to deploy any of the plans in an automated way. You can use terraform data sources and teraform remote state to refference dependencies between plans.
- I have created the Dynamo table to lock concurrent terraform changes in terraform.tf

## Accessing the cluster

Login:
```
CLUSTERNAME=my-cluster
aws eks update-kubeconfig \
  --name $CLUSTERNAME \
  --alias $CLUSTERNAME \
  --region us-east-1 \
  --role-arn arn:aws:iam::953835556803:role/joan-prova-eks
```
test the access:

```
$ kubectl get pods -A
NAMESPACE     NAME                       READY   STATUS    RESTARTS   AGE
kube-system   aws-node-rpt7z             2/2     Running   0          11m
kube-system   coredns-6dfb6d4445-dchlh   1/1     Running   0          11m
kube-system   coredns-6dfb6d4445-hvdkc   1/1     Running   0          11m
kube-system   kube-proxy-972vw           1/1     Running   0          11m
```

## Install aws-load-balancer-controller

This will create Ingress controller to create the AWS ALB that will map to a Targetgroup of the private nodes where the frontend POD's are.
The ALB will not allow any other port access than http, https.

Following https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/deploy/installation/

We will need to add annotations in the two Ingresses (front and API) to create the ALB's:

```
annotations:
  kubernetes.io/ingress.class: alb
  alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
  alb.ingress.kubernetes.io/target-type: ip
  alb.ingress.kubernetes.io/scheme: internet-facing
```

## Deploy the two app's, API and sys-stats

As App.js runs on the client's browser, we need two endpoints (two ingresses), one for the frontend (www.apily.com) and another for the API (api.apily.com), both accessible from the client's browser. 

To change this fetch endpoint we need to change the line sys-stats/../src/App.js (we canot change this dinamically, this is fixed at build time):

Replace in src/App.js fetch('http://localhost:8080/stats') --> fetch('http://api.aily.com:80/stats'), rebuild it and push the images to AWS ECR.
```
docker build -t sys-stats ./sys-stats
aws ecr get-login-password ...
docker tag ...
docker push ...

```
We can protect the API endpoint somehow keeping track of the origin (out of the scope of my implementation).


## Deploy other k8s infra components

- External-dns: to automate the creation of route53 entries based on the Ingress.
```
helm install my-release oci://registry-1.docker.io/bitnamicharts/external-dns
```
- Logs: Fluentbit or OpenTelemetry
- Prometheus/OpenTelemetry for metrics.
- Keda to scale POD's.
```
helm repo add kedacore https://kedacore.github.io/charts
helm install keda kedacore/keda --namespace keda --create-namespace
```
- Karpenter to scale nodes efficiently.

## Deploy the applications

For the Task - 3 I have created the /charts folder to be deployed in kind.
We can use these helm charts folder of the current repo with some tunning:

- Add ALB annotations in the two ingresses
```
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/listen-ports: '[{"HTTP":80}]'
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/scheme: internet-facing
```
- Change hostnames in the two ingresses instead of localhost (www.aily.com and api.aily.com)

All the app's can be deployed using GitOps in more automated way.

For the Task - 3, please return to the README that is in the root folder.