#!/bin/bash
# Script to tag and push images to ECR
# Usage: ./push.sh <registry_url> <region>

REGISTRY=$1
REGION=$2

if [ -z "$REGISTRY" ] || [ -z "$REGION" ]; then
    echo "Usage: ./push.sh <registry_url> <region>"
    echo "Example: ./push.sh 123456789012.dkr.ecr.us-east-1.amazonaws.com us-east-1"
    exit 1
fi

echo "Logging in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $REGISTRY

echo "Tagging and pushing Frontend..."
docker tag frontend:latest $REGISTRY/frontend:latest
docker push $REGISTRY/frontend:latest

echo "Tagging and pushing Backend..."
docker tag backend:latest $REGISTRY/backend:latest
docker push $REGISTRY/backend:latest

echo "Push complete!"
