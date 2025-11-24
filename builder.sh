set -e # exit immediately if a command exits with a non-zero status

usage() {
  echo "Usage: $0 <image-name> <tag-name>"
  exit 1
}

cleanup() {
  rm -rf "$TEMP_DIR"
}

if [ "$#" -ne 2 ]; then
  usage
fi

GITHUB_REPO="thomastoumasu/k8s-submission/"
DOCKER_IMAGE="thomastoumasu/k8s-${1}:${2}"
TEMP_DIR=$(mktemp -d)

# registers the cleanup function to be called on script exit
trap cleanup exit

# git clone "https://github.com/$GITHUB_REPO" "$TEMP_DIR"
git clone --depth 1 --branch ${2} "https://github.com/$GITHUB_REPO" "$TEMP_DIR"
cd $TEMP_DIR/${1}

docker build -t "$DOCKER_IMAGE" .
docker push "$DOCKER_IMAGE"

#sh builder.sh log_output 1.1