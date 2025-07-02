FROM alpine:3.22.0

# (1) 필요한 nginx, nginx 설정 변경 모듈 다운로드
RUN apk update \
 && apk add --no-cache \
  nginx="~1.28.0" \
  nginx-mod-http-headers-more

# (2) 설정 파일 COPY
COPY ./nginx.conf /etc/nginx/nginx.conf
# default.conf, Html 파일 - 테스트를 위한 기본 설정만 적용
COPY ./default.conf /etc/nginx/conf.d/default.conf
COPY ./html /usr/share/nginx/html

# (3) 로컬 테스트 시 활성화
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]