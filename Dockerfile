FROM nginx:1.13.8
MAINTAINER 4 All Digital  "joe@4alldigital.com"

RUN mkdir -p /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/nginx.conf.default /etc/nginx/nginx.conf.default

COPY ./config/drupal.conf /etc/nginx/conf.d/default.conf

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN usermod -u 500 www-data && \
    usermod -a -G users www-data

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
