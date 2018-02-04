FROM phusion/baseimage
MAINTAINER 4 All Digital  "joe@4alldigital.com"

ENV DEBIAN_FRONTEND noninteractive
ENV NGINX_VERSION 1.10.1
ENV NPS_VERSION 1.11.33.2
ENV PS_NGX_EXTRA_FLAGS  "--prefix=/etc/nginx --sbin-path=/usr/local/bin --conf-path=/etc/nginx/conf/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-http_ssl_module --with-http_realip_module --with-http_addition_module --with-http_sub_module --with-http_dav_module --with-http_flv_module --with-http_mp4_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_random_index_module --with-http_secure_link_module --with-http_stub_status_module --with-http_auth_request_module --with-mail --with-mail_ssl_module --with-file-aio --with-ipv6 --with-threads --with-stream --with-stream_ssl_module --with-http_slice_module --with-http_v2_module"
RUN locale-gen en_GB.UTF-8
ENV LANG       en_GB.UTF-8
ENV LC_ALL     en_GB.UTF-8
RUN locale-gen en_GB.UTF-8

RUN apt-get update && apt-get install -y python-software-properties && \
    add-apt-repository ppa:nginx/stable && \
    apt-get -y install curl supervisor build-essential zlib1g-dev libpcre3 \
    libpcre3-dev unzip wget wget \
    build-essential openssl libssl-dev zlib1g-dev libpcre3 libpcre3-dev unzip

RUN mkdir -p /tmp /var/log/nginx/ && cd /tmp && \
    wget https://github.com/pagespeed/ngx_pagespeed/archive/release-${NPS_VERSION}-beta.zip -O release-${NPS_VERSION}-beta.zip && \
    unzip release-${NPS_VERSION}-beta.zip && \
    cd ngx_pagespeed-release-${NPS_VERSION}-beta/ && \
    wget https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}.tar.gz && \
    tar -xzvf ${NPS_VERSION}.tar.gz && \
    rm -rf ${NPS_VERSION}.tar.gz && \
    cd /tmp && \
    wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz && \
    tar -xvzf nginx-${NGINX_VERSION}.tar.gz && \
    cd nginx-${NGINX_VERSION}/ && \
    ./configure --add-module=/tmp/ngx_pagespeed-release-${NPS_VERSION}-beta ${PS_NGX_EXTRA_FLAGS} && \
    make && make install && \
    # cleanup
    rm -fr /tmp/* /var/lib/apt/lists/* /var/tmp/* \
    && apt-get purge -y wget build-essential  libssl-dev zlib1g-dev  libpcre3-dev unzip \
    && apt-get autoremove -y \
    && apt-get autoclean \
    && apt-get clean \
    && rm -rf /tmp/* && mkdir -p /var/ngx_pagespeed_cache && mkdir -p /var/log/nginx/

RUN mkdir -p /etc/service/nginx/run
RUN chmod +x /etc/service/nginx/run

EXPOSE 80

RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir -p /var/log/supervisor /var/run/supervisor
RUN chmod -R 775 /var/log/supervisor
COPY ./config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./config/nginx.conf /etc/nginx/conf/nginx.conf
COPY ./config/pagespeed.conf /etc/nginx/conf.d/pagespeed.conf
COPY ./config/nginx.conf.default /etc/nginx/conf/nginx.conf.default

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

RUN ln -sf /dev/stdout /var/log/supervisor/nginx.out.log  \
    && ln -sf /dev/stderr /var/log/supervisor/nginx.err.log

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
