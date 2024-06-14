---
slug: migrate-consul-enterprise
id: wx5atkvowduk
type: challenge
title: Deploy Consul Enterprise on Kubernetes
teaser: Migrate from Consul OSS to Enterprise via helm chart.
tabs:
- title: GCPTerminal-1
  type: terminal
  hostname: cloud-client
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
timelimit: 15000
---

Deploy Consul Enterprise
=============================

We are going to deploy Consul Enterprise using an update version of the helm chart. If you go to ** Consul Configs** tab you will see that there's a new dc1-ent.yaml file. In there, a new section for Enterprise Licence and a new **image** have been added.

Before installing the Consul Enterprise container, we need to confirm that the license has been stored as a secret
```
kubectl get secrets -n consul --kubeconfig /root/hashi-cluster-0-ctx.config
kubectl get secrets -n consul --kubeconfig /root/hashi-cluster-1-ctx.config
```

Now, you can upgrade Consul in the first cluster:
```
consul-k8s upgrade -f /root/consul/consul_values/dc1-ent.yaml --kubeconfig /root/hashi-cluster-0-ctx.config
```

Jump to Terminal 2 and check how Consul Stateful sets is rolling out the new container images

```
kubectl get pods -n consul -w
```

And also upgrade the second cluster:

```
consul-k8s upgrade -f /root/consul/consul_values/dc2-ent.yaml --kubeconfig /root/hashi-cluster-1-ctx.config
```

Expose both clusters:
```
nohup kubectl port-forward svc/consul-ui 7443:443 --address 0.0.0.0 -n consul --kubeconfig /root/hashi-cluster-0-ctx.config &
nohup kubectl port-forward svc/consul-ui 8443:443 --address 0.0.0.0 -n consul --kubeconfig /root/hashi-cluster-1-ctx.config &
```

Once upgrade is completed, jump to DC1 and DC2 tab and you should see "Admin Partitions" and "Namespaces" in the left side menu ( both Enterprise features)

To make sure the license has been applied and you are running Consul Enterprise, run this command from the GCPTerminal

```
kubectl exec -it consul-server-0 -n consul -- consul license get --kubeconfig /root/hashi-cluster-0-ctx.config

kubectl exec -it consul-server-0 -n consul -- consul license get --kubeconfig /root/hashi-cluster-1-ctx.config
```

You should see "License Active" and all the features enabled. Congrats you are now running Consul Enterprise!
---

