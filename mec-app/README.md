# ES OBU DT :: MEC APP

ES OBU DT MEC APP using a local Helm Chart.

## Package the chart

To package the mec app, run the following commands:

1. Get the Helm chart and package it

```bash
rm -rf helm
mkdir -p helm
cp -r ../k8s/es-obu-dt-5gasp-chart helm
helm dependency update helm/es-obu-dt-5gasp-chart
tar -C helm -czvf helm.tar.gz es-obu-dt-5gasp-chart
```

2. Package the app descriptor and the Helm chart

```bash
tar -czvf es-obu-dt-mec-app.tar.gz appd.yaml helm.tar.gz
```

## Instantiate the app

### Using the GUI

To deploy the mec app you need the [OSM MEC platform](https://github.com/ATNoG/osm-mec) running with your OSM, then you go to the CFS Portal create the new app using the `es-obu-dt-mec-app.tar.gz` package and instantiate it using the variables in `vars.yaml` as configuration values.

### Using the OSS API

You can also deploy using the OSS API.

#### Deploy the package

```bash
curl -X POST "http://<oss_ip>:<oss_port>/oss/v1/app_pkgs" -H "Content-Type: multipart/form-data" -F "appd=@es-obu-dt-mec-app.tar.gz" -w "\n"
```

#### Get packages

```bash
curl -X GET "http://<oss_ip>:<oss_port>/oss/v1/app_pkgs" -w "\n"
```

#### Get VIMs

```bash
curl -X GET "http://<oss_ip>:<oss_port>/oss/v1/vims" -w "\n"
```

#### Instantiate the package

```bash
curl -X POST "http://<oss_ip>:<oss_port>/oss/v1/app_pkgs/<app_pkg_id>/instantiate" -H "Content-Type: multipart/form-data" -F "name=<name>" -F "description=<Description>" -F "vim_id=<vim_id>" -F "config=$(< vars.yaml)" -w "\n"
```

#### Get the instances

```bash
curl -X GET "http://<oss_ip>:<oss_port>/oss/v1/appis" -w "\n"
```

#### Delete the instance

```bash
curl -X POST "http://<oss_ip>:<oss_port>/oss/v1/appis/<instance-id>" -H "Content-Type: application/json" -d "{}"  -w "\n"
```

#### Delete the package

```bash
curl -X POST "http://<oss_ip>:<oss_port>/oss/v1/app_pkgs/<app_pkg_id>" -H "Content-Type: application/json" -d "{}" -w "\n"
```
