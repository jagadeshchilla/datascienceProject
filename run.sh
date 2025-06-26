#!/bin/bash

# Data Science Project Docker Runner
# Usage: ./run.sh [build|run|stop|logs]

PROJECT_NAME="datascienceproject"
CONTAINER_NAME="datascienceproject-container"
IMAGE_NAME="datascienceproject:latest"
PORT="8080"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_usage() {
    echo -e "${BLUE}Usage: $0 [build|run|stop|logs|clean]${NC}"
    echo ""
    echo "Commands:"
    echo "  build   - Build the Docker image"
    echo "  run     - Run the container (builds if needed)"
    echo "  stop    - Stop and remove the container"
    echo "  logs    - Show container logs"
    echo "  clean   - Remove container and image"
    echo ""
    echo "Environment Variables:"
    echo "  DAGSHUB_TOKEN - Your DagsHub access token (required)"
}

check_dagshub_token() {
    if [ -z "$DAGSHUB_TOKEN" ]; then
        echo -e "${RED}Error: DAGSHUB_TOKEN environment variable is not set!${NC}"
        echo "Please set your DagsHub token:"
        echo "export DAGSHUB_TOKEN=your_token_here"
        exit 1
    fi
}

build_image() {
    echo -e "${BLUE}Building Docker image...${NC}"
    docker build -t $IMAGE_NAME .
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Docker image built successfully!${NC}"
    else
        echo -e "${RED}❌ Failed to build Docker image${NC}"
        exit 1
    fi
}

run_container() {
    check_dagshub_token
    
    # Stop existing container if running
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo -e "${YELLOW}Stopping existing container...${NC}"
        docker stop $CONTAINER_NAME
    fi
    
    # Remove existing container if exists
    if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
        echo -e "${YELLOW}Removing existing container...${NC}"
        docker rm $CONTAINER_NAME
    fi
    
    # Check if image exists, build if not
    if [ "$(docker images -q $IMAGE_NAME)" = "" ]; then
        echo -e "${YELLOW}Image not found, building...${NC}"
        build_image
    fi
    
    echo -e "${BLUE}Starting container...${NC}"
    docker run -d \
        --name $CONTAINER_NAME \
        -p $PORT:8080 \
        -e MLFLOW_TRACKING_PASSWORD="$DAGSHUB_TOKEN" \
        -v "$(pwd)/artifacts:/app/artifacts" \
        -v "$(pwd)/logs:/app/logs" \
        $IMAGE_NAME
        
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ Container started successfully!${NC}"
        echo -e "${GREEN}🌐 Application available at: http://localhost:$PORT${NC}"
        echo -e "${YELLOW}📋 Use '$0 logs' to view logs${NC}"
    else
        echo -e "${RED}❌ Failed to start container${NC}"
        exit 1
    fi
}

stop_container() {
    echo -e "${BLUE}Stopping container...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME 2>/dev/null
    echo -e "${GREEN}✅ Container stopped and removed${NC}"
}

show_logs() {
    if [ "$(docker ps -q -f name=$CONTAINER_NAME)" ]; then
        echo -e "${BLUE}Container logs (Ctrl+C to exit):${NC}"
        docker logs -f $CONTAINER_NAME
    else
        echo -e "${RED}❌ Container is not running${NC}"
        exit 1
    fi
}

clean_all() {
    echo -e "${BLUE}Cleaning up...${NC}"
    docker stop $CONTAINER_NAME 2>/dev/null
    docker rm $CONTAINER_NAME 2>/dev/null
    docker rmi $IMAGE_NAME 2>/dev/null
    echo -e "${GREEN}✅ Cleanup completed${NC}"
}

# Main script logic
case "$1" in
    build)
        build_image
        ;;
    run)
        run_container
        ;;
    stop)
        stop_container
        ;;
    logs)
        show_logs
        ;;
    clean)
        clean_all
        ;;
    *)
        print_usage
        exit 1
        ;;
esac 