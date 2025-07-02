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

# (3) nginx 실행 전용 비루트 사용자/그룹 생성
RUN addgroup -g 1000 nginx-user \
 && adduser -u 1000 -G nginx-user -s /sbin/nologin -D nginx-user

# (4) 설정파일·웹루트 디렉터리 소유권을 새 사용자로 변경
RUN mkdir -p \
      /var/lib/nginx/logs \
      /var/lib/nginx/tmp/client_body \
      /var/run/nginx \
    && chown -R nginx-user:nginx-user /etc/nginx \
    && chown -R nginx-user:nginx-user /var/lib/nginx/logs \
    && chown -R nginx-user:nginx-user /usr/share/nginx/html \
    && chown -R nginx-user:nginx-user /var/lib/nginx \
    && chown -R nginx-user:nginx-user /var/run/nginx

# (5) 포트 80 비루트 사용자 권한에 맞춰서 Alpine 용 패키지인 libcap 설치 후
# – 포트 번호 1~1023(“privileged ports”) 에는 루트 권한이 있어야만 bind 할 수 있습니다.
# – USER nginx-user 로 nginx를 실행하면, 기본적으로 nginx-user 유저는 80번 포트를 열 권한이 없습니다.
# – cap_net_bind_service 라는 “비-루트 사용자도 privileged port를 바인딩할 수 있는” 커널 능력(capability) 을 nginx 실행파일에 부여
# – 이렇게 하면 nginx 프로세스가 실제로는 nginx-user(UID=1000) 권한으로 실행되면서도, 80번 포트에 문제없이 바인딩 할 수 있습니다.
RUN apk add --no-cache libcap \
 && setcap 'cap_net_bind_service=+ep' /usr/sbin/nginx

# (6) 컨테이너 실행 시점에 nginx를 nginx-user 사용자로 띄우도록 변경
USER nginx-user

# (7) 로컬 테스트 시 활성화
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]