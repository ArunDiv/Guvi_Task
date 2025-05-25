#!/bin/bash

# --- Configuration ---
# REPLACE with your Docker Hub Username
DOCKER_HUB_USERNAME="arundive"
LOCAL_SERVICE_NAME="my-react-app" # This matches the service name in your docker-compose.yml
# The local image name created by docker-compose build follows the pattern:
# project_directory_name_servicename
# Assuming your project directory is 'Guvi_Project'
LOCAL_IMAGE_NAME="guvi_project_${LOCAL_SERVICE_NAME}"

# Full Docker Hub image tags
DEV_IMAGE_FULL_TAG="${DOCKER_HUB_USERNAME}/guvi-react-app-dev:latest"
PROD_IMAGE_FULL_TAG="${DOCKER_HUB_USERNAME}/guvi-react-app-prod:latest"

echo "--- Starting Docker Build and Push ---"
echo "Docker Hub Username: $DOCKER_HUB_USERNAME"
echo "Local Service Name: $LOCAL_SERVICE_NAME"
echo "Local Image Name for tagging: $LOCAL_IMAGE_NAME"
echo "DEV Image Tag: $DEV_IMAGE_FULL_TAG"
echo "PROD Image Tag: $PROD_IMAGE_FULL_TAG"
echo "-------------------------------------"

# 1. Build the Docker image using docker-compose
# This will use your Dockerfile and build the image locally.
echo "Building local Docker image for service '$LOCAL_SERVICE_NAME'..."
docker compose build --no-cache "$LOCAL_SERVICE_NAME"
if [ $? -ne 0 ]; then
    echo "ERROR: Docker image build failed!"
    exit 1
fi
echo "Local image built: $LOCAL_IMAGE_NAME"

# 2. Log in to Docker Hub
# You will be prompted for your Docker Hub username and password/PAT.
echo "Logging into Docker Hub (you will be prompted for credentials)..."
docker login
if [ $? -ne 0 ]; then
    echo "ERROR: Docker Hub login failed!"
    exit 1
fi
echo "Successfully logged into Docker Hub."

# 3. Tag and push DEV image to Docker Hub
echo "Tagging local image as '$DEV_IMAGE_FULL_TAG'..."
docker tag "$LOCAL_IMAGE_NAME" "$DEV_IMAGE_FULL_TAG"
if [ $? -ne 0 ]; then
    echo "ERROR: Docker tag for DEV image failed!"
    exit 1
fi

echo "Pushing DEV image to Docker Hub: $DEV_IMAGE_FULL_TAG"
docker push "$DEV_IMAGE_FULL_TAG"
if [ $? -ne 0 ]; then
    echo "ERROR: Docker push for DEV image failed!"
    exit 1
fi
echo "DEV image pushed successfully."

# 4. Tag and push PROD image to Docker Hub
echo "Tagging local image as '$PROD_IMAGE_FULL_TAG'..."
docker tag "$LOCAL_IMAGE_NAME" "$PROD_IMAGE_FULL_TAG"
if [ $? -ne 0 ]; then
    echo "ERROR: Docker tag for PROD image failed!"
    exit 1
fi

echo "Pushing PROD image to Docker Hub: $PROD_IMAGE_FULL_TAG"
docker push "$PROD_IMAGE_FULL_TAG"
if [ $? -ne 0 ]; then
    echo "ERROR: Docker push for PROD image failed!"
    exit 1
fi
echo "PROD image pushed successfully."

echo "--- Build and Push Complete ---"
