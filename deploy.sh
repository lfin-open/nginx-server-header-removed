#!/bin/sh

# 코드 수정 후 배포 방법
# 1. 로컬 터미널에서 먼저 docker login 진행
# docker login -u lfin
# 2. 프로젝트 경로로 이동 후 deploy.sh 실행
# sh ./deploy.sh

# -------- Docker Image 빌드 및 업로드 ------------------
# 1. Buildx 빌더 생성 / 활성화
BUILDER_NAME="mybuilder"

# buildx mybuilder 이름으로 생성, 활성화 # 이미 있으면 skip, 없으면 생성
if ! docker buildx ls | grep -q "${BUILDER_NAME}"; then
  echo "🔧 Creating buildx builder (${BUILDER_NAME})…"
  docker buildx create --name "${BUILDER_NAME}" --use --bootstrap
else
  echo "✅ Using existing buildx builder (${BUILDER_NAME})"
  docker buildx use "${BUILDER_NAME}"
fi

IMG_PREFIX="lfin"
IMG_NAME="nginx-server-header-removed"

# 2. nginx 와 alpine 버전 기준으로 태그 생성 (** 버전 변경 시 변경 필수! **)
VERSION="1.28.0-alpine3.22.0"

IMAGE_NAME_WITH_VERSION="${IMG_PREFIX}/${IMG_NAME}:${VERSION}"
IMAGE_NAME_LATEST="${IMG_PREFIX}/${IMG_NAME}:latest"

echo "🐳 Building Docker image"
echo "$VERSION"
echo "$IMAGE_NAME_WITH_VERSION"

# 3. nginx 와 alpine 버전 기준 및 latest 각각 multi 플랫폼 빌드 후 push
docker buildx build  --platform linux/amd64,linux/arm64 -f Dockerfile \
  --push -t $IMAGE_NAME_WITH_VERSION  . --no-cache

docker buildx build  --platform linux/amd64,linux/arm64 -f Dockerfile \
  --push -t $IMAGE_NAME_LATEST  . --no-cache
