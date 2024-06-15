## Build and push
```
docker build . -t harbor.patras5g.eu/netapp/es-obu-dt-5gasp:latest
docker push harbor.patras5g.eu/netapp/es-obu-dt-5gasp:latest
```

## Run
```
docker run -d -p 1883:1883 -p 9000:9000 --name es-obu-dt-5gasp harbor.patras5g.eu/netapp/es-obu-dt-5gasp:latest
# OR
docker compose up -d
```

## Helm Chart

```
# Install Local
microk8s.helm install es-obu-dt-5gasp k8s/es-obu-dt-5gasp-chart \
    --set es_obu_dt_5gasp.env.brokerPassword=dummyPassword \
    --set es_obu_dt_5gasp.env.brokerUsername=dummyUsername \
    --set es_obu_dt_5gasp.env.brokerUrl=dummyUrl

# Uninstall Local
microk8s.helm uninstall es-obu-dt-5gasp

# Push Helm Chart to Harbor
microk8s.helm registry login harbor.patras5g.eu/netapp
microk8s.helm package k8s/es-obu-dt-5gasp-chart/ 
microk8s.helm push es-obu-dt-5gasp-chart-0.1.0.tgz oci://harbor.patras5g.eu/chartrepo/netapp

# Install from Harbor
microk8s.helm repo update
microk8s.helm install \
    --set es_obu_dt_5gasp.env.brokerPassword=dummyPassword \
    --set es_obu_dt_5gasp.env.brokerUsername=dummyUsername \
    --set es_obu_dt_5gasp.env.brokerUrl=dummyUrl \
    es-obu-dt-5gasp-chart harbor.patras5g.eu/es-obu-dt-5gasp-chart

# Uninstall
microk8s.helm uninstall es-obu-dt-5gasp-chart
```

## Stop and remove
```
docker stop dt_endpoint
docker container rm dt_endpoint
```
