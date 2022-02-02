VERSION="$1"
OVERRIDE="$2"
REPO_TOKEN="$3"

GITHUB_REPOSITORY="${GITHUB_REPOSITORY,,}"

docker login ghcr.io -u ${GITHUB_REF} -p ${REPO_TOKEN}

VERSION=$VERSION docker-compose -f docker-compose.yml -f $OVERRIDE up --no-start --remove-orphans
IMAGES=$(docker inspect --format='{{.Image}}' $(docker ps -aq))

echo "IMAGES: $IMAGES"
for IMAGE in $IMAGES; do
    echo "IMAGE: $IMAGE"

    APPEND=$(docker inspect --format '{{ index .RepoTags }}' $IMAGE 2>/dev/null | grep -oP '(?<=\[).*?(?=\:)') 
    echo $?
    if [ $? -eq 0 ]; then
	if [ -n "$APPEND" ]; then
	    NAME=$(basename ${GITHUB_REPOSITORY}).$APPEND
	    TAG="ghcr.io/${GITHUB_REPOSITORY}/$NAME:$VERSION"
	    echo "Tagging and pushing $TAG"

	    docker tag $IMAGE $TAG
	    docker push $TAG
	fi
    fi
done
