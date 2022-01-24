# Theia Cloud

## Running

### Local Setup with Minikube

#### Initial Setup

Remove old Minikube clusters with `minikube delete`.

Start a new Minikube instance:\
`minikube start --addons=ingress --vm=true --memory=8192 --cpus=6 --disk-size=75g --vm-driver=virtualbox`

Create a new namespace and switch to it:\
`kubectl create namespace theiacloud`\
`kubectl config set-context --current --namespace=theiacloud`

Install custom resource definitions (from git root directory):\
`kubectl apply -f k8s/operator-k8s-yaml/template-spec-resource.yaml`\
`kubectl apply -f k8s/operator-k8s-yaml/workspace-spec-resource.yaml`

Launch operator from Eclipse.

Install sample template (from git root directory):\
`kubectl apply -f demo/k8s/demo-k8s-yaml/coffee-teplate-spec.yaml`\
`kubectl apply -f demo/k8s/demo-k8s-yaml/coffee-workspace-1.yaml`\
`kubectl apply -f demo/k8s/demo-k8s-yaml/coffee-workspace-2.yaml`
