FROM nginx:1.13.8
MAINTAINER 4 All Digital  "joe@4alldigital.com"

RUN mkdir -p /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

COPY ./config/nginx.conf /etc/nginx/conf/nginx.conf
COPY ./config/nginx.conf.default /etc/nginx/conf/nginx.conf.default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
