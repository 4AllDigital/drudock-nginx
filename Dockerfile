FROM nginx:1.13.8-alpine-perl
MAINTAINER 4 All Digital  "joe@4alldigital.com"

ENV DNS_RESOLVER 127.0.0.11

RUN mkdir -p /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx.conf.default /etc/nginx/nginx.conf.default

COPY ./config/drupal.conf /etc/nginx/conf.d/default.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
