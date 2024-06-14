---
slug: deploying-consul-clusters
id: dr4wgswxna1z
type: challenge
title: Deploy Consul servers
teaser: Have fun with Consul deployment and migration
notes:
- type: text
  contents: |-
    This track uses a Consul deployment in two different Kubernetes clusters.
    **Please, be patient and go for a coffee or a walk in the meantime**. This will take around 8 minutes to deploy all K8s clusters and prepare the environment.

    ## Objectives

    In this track, this is what you'll learn:
    - Deploy GKE clusters in two regions
    - Install Consul OSS version in both clusters
    - Deploy a backend and frontend application one on each cluster
tabs:
- title: GCP-Terminal-1
  type: terminal
  hostname: cloud-client
tabs:
- title: GCP-Terminal-2
  type: terminal
  hostname: cloud-client
- title: Consul values
  type: code
  hostname: cloud-client
  path: /root/consul
- title: DC1
  type: service
  hostname: cloud-client
  path: /
  port: 7443
- title: DC2
  type: service
  hostname: cloud-client
  path: /
  port: 8443
- title: GCP Console
  type: service
  hostname: cloud-client
  path: /
  port: 80
difficulty: basic
timelimit: 7200
---

---

👋 Deploy Environment
=====================


We are going to use different K8s kubeconfigs files to play with different GKE clusters in the same terminal. You can also get the required contexts for your clusters if you want:

```
gcloud container clusters get-credentials hashi-cluster-0 --zone europe-southwest1-b
gcloud container clusters get-credentials hashi-cluster-1 --zone europe-west1-c
```

Check your contexts:

```
kubectl config get-contexts
```

We already deployed some K8s secrets for you in order to install Consul, including the `bootstrap token` and the Enterprise license ( which will be use in the next challenge).

You can check all the required secrets in both clusters:
```
for i in {0..1};do
echo "===> GKE $i"
kubectl get secret -n consul --kubeconfig /root/hashi-cluster-$i-ctx.config
done
```

Now, you can install Consul in the first cluster:
```
consul-k8s install -namespace consul -f /root/consul/consul_values/dc1.yaml --kubeconfig /root/hashi-cluster-0-ctx.config
```

Jump to Terminal-2 and install Consul in the second cluster:
```
consul-k8s install -namespace consul -f /root/consul/consul_values/dc2.yaml --kubeconfig /root/hashi-cluster-1-ctx.config
```

Expose both clusters:
```
nohup kubectl port-forward svc/consul-ui 7443:443 --address 0.0.0.0 -n consul --kubeconfig /root/hashi-cluster-0-ctx.config &
nohup kubectl port-forward svc/consul-ui 8443:443 --address 0.0.0.0 -n consul --kubeconfig /root/hashi-cluster-1-ctx.config &
```

`You should see them now available in DC1 and DC2 tab`


It's time now to deploy an application in both clusters. Frontend application will be hosted in cluster-0 and backend in cluster-1:
```
kubectl apply -f /root/consul/apps/backend.yaml --kubeconfig /root/hashi-cluster-1-ctx.config
kubectl apply -f /root/consul/apps/frontend.yaml --kubeconfig /root/hashi-cluster-0-ctx.config
```


