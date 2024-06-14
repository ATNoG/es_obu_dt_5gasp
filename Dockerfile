FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update --allow-insecure-repositories && apt install -y apt-transport-https software-properties-common wget curl jq gettext --allow-unauthenticated
RUN wget -q -O - https://packages.grafana.com/gpg.key | apt-key add -
RUN echo "deb https://packages.grafana.com/oss/deb stable main" | tee -a /etc/apt/sources.list.d/grafana.list

RUN apt update --allow-insecure-repositories && apt install -y grafana mosquitto --allow-unauthenticated
RUN mkdir -p /etc/mosquitto /var/lib/mosquitto /var/log/mosquitto
RUN mkdir -p /etc/grafana /var/lib/grafana /var/log/grafana
COPY mosquitto.conf /etc/mosquitto/mosquitto.conf
COPY grafana.ini /etc/grafana/grafana.ini
RUN grafana-cli plugins install grafana-mqtt-datasource
RUN apt clean

COPY dashboard_template.json /dashboard_template.json
COPY datasource_template.json /datasource_template.json

COPY start_services.sh /bin/start_services.sh
RUN chmod +x /bin/start_services.sh

EXPOSE 1883 9000
CMD ["/bin/start_services.sh"]
