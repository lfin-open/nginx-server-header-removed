FROM alpine:3.22.0

RUN apk update \
 && apk add --no-cache \
  nginx="~1.28.0" \
  nginx-mod-http-headers-more

COPY ./nginx.conf /etc/nginx/nginx.conf
# default.conf, Html 파일 - 테스트를 위한 기본 설정만 적용
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./html /usr/share/nginx/html

# 로컬 테스트 시 활성화
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]