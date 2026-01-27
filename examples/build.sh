#!/bin/bash
# Script to build docker images locally

set -e

echo "Building Frontend..."
docker build -t frontend:latest ./frontend

echo "Building Backend..."
docker build -t backend:latest ./backend

echo "Build complete!"
