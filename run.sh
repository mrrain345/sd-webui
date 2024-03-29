#!/bin/sh

DOCKERHUB_USER=mrrain345

function help() {
  echo "Usage: $(basename $0) [run [cmd]|build|rebuild [cmd]|publish [user]|help]"
  echo "  run [cmd]:      Run the container."
  echo "  build:          Build the container."
  echo "  rebuild [cmd]:  Build and run the container."
  echo "  publish [user]: Publish the container to Docker Hub. (user defaults to $DOCKERHUB_USER)"
  echo "  help:           Print this help."
}

function run() {
  docker run --rm --gpus all \
    --name sd-webui \
    -p 7860:7860 \
    -p 5173:5173 \
    -v ./data:/data \
    -it sd-webui "$@"
}

function build() {
  docker build . -t sd-webui
}

function rebuild() {
  build && run "$@"
}

function publish() {
  local user=${1:-$DOCKERHUB_USER}
  docker build . -t sd-webui
  docker tag sd-webui $user/sd-webui
  docker push $user/sd-webui
}


pushd $(dirname $0) > /dev/null
ACTION=${1:-help}
shift 2> /dev/null

case $ACTION in
  run) run "$@";;
  build) build;;
  rebuild) rebuild "$@";;
  publish) publish "$@";;
  help) help;;
  *) echo "Unknown action: $ACTION"; help; exit 1;;
esac

popd > /dev/null
