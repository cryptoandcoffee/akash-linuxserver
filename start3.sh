#!/bin/bash

# Define the YAML template
YAML_TEMPLATE=$(cat template3.yaml)

# Get top 30 Docker images from LinuxServer.io and other popular Docker Hub maintainers
#DOCKER_IMAGES=$(curl -sSL "https://index.docker.io/v1/search?q=user%3Alinuxserver+OR+user%3Acontainrrr+OR+user%3Ahaugene" | jq -r '.results[] | .name')

#DOCKER_IMAGES=$(curl -sSL "https://hub.docker.com/v2/repositories/linuxserver/?page_size=200" | jq -r '.results[].name')
#Second 100 
#DOCKER_IMAGES=$(curl -sSL "https://hub.docker.com/v2/repositories/linuxserver/?page=1&page_size=100" | jq -r '.results[].name')
DOCKER_IMAGES=""

for i in $(seq 1 5); do
    IMAGES=$(curl -sSL "https://hub.docker.com/v2/repositories/linuxserver/?page=$i&page_size=100" | jq -r '.results[].name')
    DOCKER_IMAGES="$DOCKER_IMAGES $IMAGES"
    sleep 5
done

echo $DOCKER_IMAGES



# Remove Docker images that exist on Akash Awesome
AKASH_AWESOME_URL="https://raw.githubusercontent.com/akash-network/awesome-akash/main/README.md"
AKASH_AWESOME=$(curl -sSL $AKASH_AWESOME_URL)
for DOCKER_IMAGE in $DOCKER_IMAGES; do
  if grep -q "$DOCKER_IMAGE" <<< "$AKASH_AWESOME"; then
    DOCKER_IMAGES=$(sed "/$DOCKER_IMAGE/d" <<< "$DOCKER_IMAGES")
  fi
done

# Loop through the Docker images and generate YAML files
for DOCKER_IMAGE in $DOCKER_IMAGES; do
  # Create directory for application
  APP_NAME=$(echo "$DOCKER_IMAGE" | cut -d'/' -f2)

  mkdir -p "$APP_NAME"

  # Get README file and extract the docker run command
  README=$(curl -sSL "https://hub.docker.com/v2/repositories/linuxserver/$DOCKER_IMAGE/?page_size=1" | jq -r '.full_description')
#  echo $README
  DOCKER_RUN_COMMAND=$(echo "$README")

  # Extract environment variables and ports from docker run command
  ENV_VARS=$(echo "$DOCKER_RUN_COMMAND" | awk -F '-e ' '{ for (i=2; i<=NF; i++) print $i }' | sed 's/\$.*//; s/\s.*//' | sed 's/`//g' | sort -u | sed 's/FILE__PASSWORD=\/run\/secrets\/mysecretpassword/PASSWORD='$(openssl rand -hex 16)'/g' | grep -v "PGID" | grep -v "PUID" | grep -v "UMASK" | grep -v "NVIDIA_VISIBLE_DEVICES")
#  ENV_VARS=$(echo $ENV_VARS | grep -v "FILE__PASSWORD=" | grep -v "PGID" | grep -v "UID" | grep -v "UMASK")
#curl -sSL "https://hub.docker.com/v2/repositories/linuxserver/plex/?page_size=1" | jq -r .full_description | awk -F '-e ' '{ for (i=2; i<=NF; i++) print $i }' | sed 's/\$.*//; s/\s.*//' | sed 's/`//g' | sort -u
  echo $ENV_VARS
  PORTS=""
  for PORT in $(echo "$DOCKER_RUN_COMMAND" | grep -oE '\-p [0-9]+:[0-9]+' | sed 's/^-p //'); do
    if [[ ! " $PORTS " =~ " ${PORT#*:} " ]]; then
      PORTS="$PORTS      - port: ${PORT#*:}\n        as: ${PORT#*:}\n        to:\n          - global: true\n"
    fi
  done

  # Generate YAML file
  ENV_VARS_YAML=""
  for ENV_VAR in $ENV_VARS; do
    if [[ ! " $ENV_VARS_YAML " =~ " ${ENV_VAR%=*} " ]]; then
      ENV_VARS_YAML="$ENV_VARS_YAML      - ${ENV_VAR%=*}=${ENV_VAR#*=}\n"
    fi
  done
  YAML=$(echo -e "$YAML_TEMPLATE" | sed -e "s#{APP_NAME}#$APP_NAME#g" -e "s#{DOCKER_IMAGE}#$DOCKER_IMAGE#g" -e "s#{ENVIRONMENT_VARIABLES}#$ENV_VARS_YAML#g" -e "s#{PORTS}#$PORTS#g")

  echo -e "$YAML" > "$APP_NAME/deploy.yaml"
  rm "$APP_NAME/$APP_NAME.yaml"

  # Save README file in application directory
  echo -e "$README" > "$APP_NAME/README.md"
done
