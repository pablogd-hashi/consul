```
consul acl policy create -name gitlab-pol \
   -rules='service_prefix "" { policy="read" } node_prefix "" { policy="read" }'
```

```
consul acl role create -name gitlab-ro -policy-name gitlab-pol
```

```
consul acl auth-method create -type oidc \
    -name gitlab \
    -max-token-ttl=5m \
    -config=@auth-method-config.json
```