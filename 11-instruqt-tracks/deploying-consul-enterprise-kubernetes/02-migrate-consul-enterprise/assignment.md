---
slug: migrate-consul-enterprise
id: wx5atkvowduk
type: challenge
title: Deploy Consul Enterprise on Kubernetes
teaser: Migrate from Consul OSS to Enterprise via helm chart.
tabs:
- title: GCPTerminal-2
  type: terminal
  hostname: cloud-client
- title: Consul Configs
  type: code
  hostname: cloud-client
  path: /root/consul
- title: App Configs
  type: code
  hostname: cloud-client
  path: /root/app
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

Deploy Consul Enterprise
=============================

We are going to deploy Consul Enterprise using an update version of the helm chart. If you go to ** Consul Configs** tab you will see that there's a new ent_dc1.yaml and new_en file. In there, a new section for Enterprise Licence and a new **image** have been added.

Before installing the Consul Enterprise container, we need to confirm that the license has been stored as a secret
```
kubectl get secrets -n consul --kubeconfig /root/hashi-cluster-0-ctx.config
kubectl get secrets -n consul --kubeconfig /root/hashi-cluster-1-ctx.config
```

Now, you can install Consul in the first cluster:
```
consul-k8s install -namespace consul -f /root/consul/consul_values/dc1-ent.yaml --kubeconfig /root/hashi-cluster-0-ctx.config
```

And also in the second cluster:
```
consul-k8s install -namespace consul -f /root/consul/consul_values/dc2-ent.yaml --kubeconfig /root/hashi-cluster-1-ctx.config
```

Expose both clusters:
```
nohup kubectl port-forward svc/consul-ui 7443:443 --address 0.0.0.0 -n consul --kubeconfig /root/hashi-cluster-0-ctx.config &
nohup kubectl port-forward svc/consul-ui 8443:443 --address 0.0.0.0 -n consul --kubeconfig /root/hashi-cluster-1-ctx.config &
```
---
