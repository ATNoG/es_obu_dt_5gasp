#!/bin/bash
# @Author: Rafael Direito
# @Date:   2024-06-04 16:36:42
# @Last Modified by:   Rafael Direito
# @Last Modified time: 2024-06-14 12:05:41
#!/bin/sh

mosquitto -c /etc/mosquitto/mosquitto.conf &
# Start grafana-server in the background
grafana-server --config=/etc/grafana/grafana.ini --homepath=/usr/share/grafana &
# Store the PID of grafana-server
GRAFANA_PID=$!


# URL of the Grafana health API
URL="http://localhost:9000/api/health"
# Timeout in seconds (5 minutes)
TIMEOUT=300
# Time interval between checks in seconds
INTERVAL=5
# Start time
START_TIME=$(date +%s)
# Variable to track API readiness
api_ready=false
# URL of the Grafana datasource API
DATASOURCE_URL="http://127.0.0.1:9000/api/datasources"
# URL of the Grafana dashboard API
DASHBOARD_URL="http://127.0.0.1:9000/api/dashboards/db"

# Function to check Grafana API health
check_grafana_health() {
    response=$(curl -s $URL)
    database_status=$(echo $response | jq -r '.database')
    if [ "$database_status" == "ok" ]; then
        echo "Grafana API is ready. Database status: $database_status"
        api_ready=true
    else
        echo "Grafana API is not ready yet."
    fi
}

# Loop until timeout is reached
while true; do
    current_time=$(date +%s)
    elapsed_time=$((current_time - START_TIME))
    if [ $elapsed_time -ge $TIMEOUT ]; then
        exit 1
    fi
    
    # Check Grafana API health
    check_grafana_health

    if [ "$api_ready" = true ]; then
        break
    fi
    sleep $INTERVAL
done

# Load the dashboard JSON payload from the file, substituting the uid
DATASOURCE_PAYLOAD=$(envsubst < datasource_template.json)

export DATASOURCE_UID=""
# Send the request and capture the response and HTTP status code
response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --location "$DATASOURCE_URL" \
  --header "Content-Type: application/json" \
  --data "$DATASOURCE_PAYLOAD")

# Extract the body and HTTP status code
body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
http_status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

# Check if the status code is 200
if [ "$http_status" -eq 200 ]; then
  # Extract the UID from the JSON response
  export DATASOURCE_UID=$(echo "$body" | jq -r '.datasource.uid')
  echo "Datasource added successfully!. Datasource UID: $DATASOURCE_UID"
else
  echo "Failed to add datasource. HTTP status code: $http_status"
  exit 1
fi

# Load the dashboard JSON payload from the file, substituting the uid
DASHBOARD_PAYLOAD=$(envsubst < dashboard_template.json)

# Send the request to create the dashboard
response=$(curl --silent --write-out "HTTPSTATUS:%{http_code}" --location "$DASHBOARD_URL" \
  --header "Content-Type: application/json" \
  --data "$DASHBOARD_PAYLOAD")

# Extract the body and HTTP status code
body=$(echo "$response" | sed -e 's/HTTPSTATUS\:.*//g')
http_status=$(echo "$response" | tr -d '\n' | sed -e 's/.*HTTPSTATUS://')

# Check if the status code is 200
if [ "$http_status" -eq 200 ]; then
  echo "Dashboard created successfully"
else
  echo "Failed to create dashboard. HTTP status code: $http_status"
  echo "Response body: $body"
  exit 1
fi

wait $GRAFANA_PID
