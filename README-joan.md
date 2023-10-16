# Task-1 dockerize the application and run it

Clean you local environment with the corresponding "docker system prune -a" commands.

I have used multistage builds to reduce the size of the images. The frontend only uses static files, so a nginx is going to serve them.

This command will build and start the 2 containers (api, sys-stats):
```
docker-compose up
```
Access to http://localhost/ from your browser.

Stop docker-compose:
```
docker-compose down
```
Note: I have considered that three containers are not necessary, because as frontend I already use a nginx, serving the static files. The container image is reduced drastically to 43.2MB in this way.

Anyway, just to show how would be a reverse proxy in front of sys-stats in folder /reverse-proxy, there is the configuration.

# Task 2 - Deploy on AWS with terraform

See the README in /terraform folder

# Task 3 - Get it to work with Kubernetes

## Create kind cluster with ingress to expose pot 80

### Create kind cluster
```
kind create cluster --name aily --config ./kind/kind.config
```
Install Nginx Ingress Controller
```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```
## Rebuild sys-stats and upload the images to Kind Aily cluster

Replace in src/App.js fetch('http://localhost:8080/stats') --> fetch('http://localhost:80/stats') and rebuild it
```
docker build -t sys-stats ./sys-stats
````
Upload local images to Kind
```
kind load docker-image sys-stats:latest --name aily
kind load docker-image api:latest --name aily
```

Note: I use latest tag in images to simplify the CICD, but in production the tags could be something like production-release-comitid

## helm charts install
Create the namespace
```
kubectl create namespace aily
```
Install api
```
helm install api ./charts/api --namespace aily 
```
Install sys-stats
```
helm install sys-stats ./charts/sys-stats --namespace aily 
```

Access from your browser http://localhost after a while.

## (extra) How to manage the continuous deployment with FluxCD

### Deploying new container image tags of API and sys-stats
Using [Flux Image Automation](https://fluxcd.io/flux/guides/image-update/) we can make that Flux Image Automation controllers poll periodically AWS ECR for new image tags of api and sys-stats.

Once a new container image tag is discovered, Flux controller will commit in the repo the new tag, more precisely, in the helm deployment image field of the yaml manifest the new tag and Flux will deploy it.

### Deploying changes in infrastructure
Once Flux is installed (flux install...), with its own set of controllers with access to Git, we can create a folders structure using kustomization.yaml gitrepository.yaml and helmrelease.yaml 
which will be in charge of deploying automatically the helm charts updates once we update our Git repo.

helmrelease.yaml for API:
```
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: api
spec:
  releaseName: api
  interval: 5m
  chart:
    spec:
      chart: charts/api/
      sourceRef:
        kind: GitRepository
        name: flux-system
        namespace: flux-system
      interval: 5m
  values:
    app:
    image: "api:latest"
    resources:
        requests:
        cpu: 200m
        memory: 64Mi
        limits:
        cpu: 500m
        memory: 256Mi
    replicas: 1
```
and kustomization.yaml for API:
````
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: development-dev-1-avro-schema-registry
resources:
  - namespace.yaml
  - helmrelease.yaml
```

## Task 4 - AWS Tooling

In folder /cli is the Go coding and the instructions to run it.
