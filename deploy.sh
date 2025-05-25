#!/bin/bash

# --- Configuration ---
# REPLACE with your Docker Hub Username
DOCKER_HUB_USERNAME="arundive"
SERVICE_NAME="my-react-app" # This matches the service name in your docker-compose.yml

# Full Docker Hub image tags
DEV_IMAGE_FULL_TAG="${DOCKER_HUB_USERNAME}/guvi-react-app-dev:latest"
PROD_IMAGE_FULL_TAG="${DOCKER_HUB_USERNAME}/guvi-react-app-prod:latest"

echo "--- Starting Deployment ---"
echo "Docker Hub Username: $DOCKER_HUB_USERNAME"
echo "Service Name: $SERVICE_NAME"
echo "---------------------------"

# 1. Check for deployment environment argument
if [ -z "$1" ]; then
  echo "Error: Please specify 'dev' or 'prod' as an argument."
  echo "Usage: ./deploy.sh [dev|prod]"
  exit 1
fi

DEPLOY_ENV="$1"
DEPLOY_IMAGE=""

# 2. Determine which image to deploy based on the argument
if [ "$DEPLOY_ENV" == "dev" ]; then
  DEPLOY_IMAGE="$DEV_IMAGE_FULL_TAG"
elif [ "$DEPLOY_ENV" == "prod" ]; then
  DEPLOY_IMAGE="$PROD_IMAGE_FULL_TAG"
else
  echo "Error: Invalid environment '$DEPLOY_ENV'. Use 'dev' or 'prod'."
  exit 1
fi

echo "Deploying $DEPLOY_ENV environment."
echo "Image to deploy: $DEPLOY_IMAGE"

# 3. Log in to Docker Hub (will prompt for password if not already logged in)
echo "Logging into Docker Hub (you may be prompted for credentials)..."
docker login
if [ $? -ne 0 ]; then
    echo "ERROR: Docker Hub login failed!"
    exit 1
fi
echo "Successfully logged into Docker Hub."

# 4. Stop and remove any existing containers for this project
echo "Stopping and removing existing containers for '$SERVICE_NAME'..."
# Use docker-compose down to ensure all related components are removed
docker compose down
echo "Existing containers stopped and removed (if any)."

# 5. Pull the specified image from Docker Hub
echo "Pulling latest image from Docker Hub: $DEPLOY_IMAGE"
docker pull "$DEPLOY_IMAGE"
if [ $? -ne 0 ]; then
    echo "ERROR: Docker image pull failed!"
    exit 1
fi
echo "Image pulled successfully."

# 6. Create a temporary docker-compose file to use the pulled image
# This is necessary because your main docker-compose.yml uses 'build' context,
# but for deployment, we want to specify a pre-built 'image'.
echo "Creating temporary docker-compose file to deploy '$DEPLOY_IMAGE'..."
cat > docker-compose.temp.yml <<EOF
version: '3.8'
services:
  ${SERVICE_NAME}: # This must match your service name in original docker-compose.yml
    image: ${DEPLOY_IMAGE}
    ports:
      - "80:80"
    restart: always # Ensure the container restarts if it crashes
EOF
echo "Temporary docker-compose file created: docker-compose.temp.yml"

# 7. Start the container using the temporary file
echo "Starting new container for '$SERVICE_NAME' using '$DEPLOY_IMAGE'..."
docker compose -f docker-compose.temp.yml up -d
if [ $? -ne 0 ]; then
    echo "ERROR: Container startup failed!"
    exit 1
fi
echo "New container started successfully."

# 8. Clean up the temporary docker-compose file
echo "Cleaning up temporary docker-compose file..."
rm docker-compose.temp.yml
echo "Temporary file removed."

echo "--- Deployment of $DEPLOY_IMAGE to $DEPLOY_ENV complete! ---"
echo "Check running containers: docker ps"
echo "Access your app at: http://<YOUR_EC2_PUBLIC_IP>:80"
