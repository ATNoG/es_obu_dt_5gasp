## Build and run
```
docker build . -t dt_endpoint
docker run -d -p 1883:1883 -p 9000:9000 --name dt_endpoint dt_endpoint
```

## Stop and remove
```
docker stop dt_endpoint
docker container rm dt_endpoint
```
