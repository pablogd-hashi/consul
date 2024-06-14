## Provision a GKE cluster

### Pre-requisites

* a GCP account
* a configured gcloud SDK
* kubectl

### Installation


1) Go to 03-gke folder 
2) Replace the values in your terraform.tfvars file with your project_id and region. Terraform will use these values to target your project when provisioning your resources. 
3) Run:
    ``` 
    terraform init
    terraform plan
    terraform apply
    ```
4) Configure kubectl
```
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) --region $(terraform output -raw region)

```


### Install Consul

Go to 02-consul folder and install via helm:

```
helm install consul -n consul hashicorp/consul -f ../06-consul/values_oss.yaml --set "global.datacenter=consul-gke"

```

Feel free to edit any of the parameters, but by default this chart enables:
* Metrics in the Consul UI
* Prometheus Envoy Metrics exposed in /metrics on port 20200
* Configures Prometheus as source for Consul UI along with Grafana Dashboard URL.

For simplification of this PoC, the URL for Grafana and Prometheus have been hardcoded. Should you have an ingress or a FQDN address, edit the fields accordingly.




## Install Loki, Prometheus

This Helm chart will install and configure Prometheus, Loki & Grafana and configure all their dependencies in the default namespace. 

For more details see the Loki installation guide.

Go to 03-loki-grafana-prometheus folder and run:

```
helm install --values ../03-grafana/loki_stack.yaml loki grafana/loki-stack

```

Some parameters you can modify from the helm chart:

**grafana.persistence.size** – specifies the volume size used by Grafana to store its configuration;

**prometheus.server.persistentVolume.size** – specifies the volume size used by Prometheus to store metrics;

**prometheus.server.retention** – specifies how long metrics are kept by Prometheus before they will be discarded;

**loki.persistence.size** – specifies the volume size used by Loki to store logs;

**loki.config.chunk_store_config.max_look_back_period** – specifies the maximum retention period for storing chunks (compressed log entries);

**loki.config.table_manager.retention_period** – specifies the maximum retention period for storing logs in indexed tables;

**promtail.enabled** – specifies whether the Promtail component should be installed.

## Grafana

After installing the Loki helmchart, OOtB Grafana will include the Prometheus and Grafana datasources. Import the Consuldashboard.json to see the metrics and logs.




