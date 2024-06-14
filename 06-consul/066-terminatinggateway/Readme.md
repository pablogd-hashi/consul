## Register the external service instance as a Consul service

https://developer.hashicorp.com/consul/tutorials/connect-services/terminating-gateway

export SERVICE_ENDPOINT=

example: 


 ~/Documents/Infrastructure/k8s/06-consul/066-terminatinggateway curl -k --request PUT --data @cloudsql_external-service.json --header "X-Consul-Token: $CONSUL_HTTP_TOKEN" $CONSUL_HTTP_ADDR/v1/catalog/register 
Handling connection for 8500
true%          

### Notice that managed-aws-rds.virtual.consul resolves to a multicast IP address, which facilitates one-to-many communication for all instances of the managed-aws-rds Consul service.


➜ ~/Documents/Infrastructure/k8s/06-consul/066-terminatinggateway kubectl exec -it svc/consul-gke-server -- /bin/sh   
Defaulted container "consul" out of: consul, locality-init (init)
/ $ nslookup -port=8600 34.122.127.157 127.0.0.1
Server:         127.0.0.1
Address:        127.0.0.1:8600

157.127.122.34.in-addr.arpa     name = Cloud SQL.node.consul-gke.consul

➜ ~/Documents/Infrastructure/k8s/06-consul/066-terminatinggateway git:(master) ✗ consul acl policy create -name "managedcloudsql-write-policy" -datacenter "consul-gke" -rules @write-acl-policy.hcl 
Handling connection for 8501
ID:           9b1413b9-eb7c-93fd-e9a5-f5a2641dc390
Name:         managedcloudsql-write-policy
Partition:    default
Namespace:    default
Description:  
Datacenters:  
Rules:
# Set write access for external managed-aws-rds service
service "managedcloudsql" {
  policy = "write"
  intentions = "read"
}




 ~/Documents/Infrastructure/k8s/06-consul/066-terminatinggateway git:(master) ✗ consul acl role update -id $TGW_ACL_ROLE_ID \
                       -datacenter "consul-gke" \
                       -policy-name managedcloudsql-write-policy

Handling connection for 8501
ID:           cff02dcb-4a1c-6be5-90d8-b0cbea6ee093
Name:         consul-gke-terminating-gateway-acl-role
Partition:    default
Namespace:    default
Description:  ACL Role for consul-gke-terminating-gateway
Policies:
   8c58e1fe-5bff-68a1-8266-11a15942e0dc - terminating-gateway-policy
   9b1413b9-eb7c-93fd-e9a5-f5a2641dc390 - managedcloudsql-write-policy
