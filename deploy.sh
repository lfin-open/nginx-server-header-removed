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

# 2. docker latest, current 태그 변수 생성
NOW="$(date +%Y)$(date +%m)$(date +%d)-$(date +%H)$(date +%M)"

IMAGE_NAME_CURRENT="${IMG_PREFIX}/${IMG_NAME}:${NOW}"
IMAGE_NAME_LATEST="${IMG_PREFIX}/${IMG_NAME}:latest"

echo "🐳 Building Docker image"
echo "$NOW"
echo "$IMAGE_NAME_CURRENT"
echo "$IMAGE_NAME_LATEST"

# 3. docker latest, current 각각 multi 플랫폼 빌드 후 push
docker buildx build  --platform linux/amd64,linux/arm64 -f Dockerfile \
  --push -t $IMAGE_NAME_CURRENT  . --no-cache

docker buildx build  --platform linux/amd64,linux/arm64 -f Dockerfile \
  --push -t $IMAGE_NAME_LATEST  . --no-cache