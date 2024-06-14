## Instructions

 Start the sidecar proxy for the counting service. Since Envoy is already installed on the app server, you can just run the following command:

```
consul connect envoy -sidecar-for "app-counting-service" &

```

## In this lab, you'll deploy an ingress gateway and register the upstream service

```
Kind = "ingress-gateway"
Name = "ingress-gateway-service"

Listeners = [
 {
   Port = 8080
   Protocol = "tcp"
   Services = [
     {
       Name = "counting"
     }
   ]
 }
]
```

Note the Kind is ingress-gateway, and we're defining a listener on port 8080 that will direct traffic to the counting service. This is how external applications/users will access the counting service.

