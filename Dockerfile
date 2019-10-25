FROM alpine:3.10

ENV NODE_ENV production
WORKDIR /app

RUN apk upgrade && apk update && apk add --no-cache curl ca-certificates && \
# Add 'nginx' group and user
    addgroup -S nginx && \
    adduser -SDG nginx nginx && \
    curl -o /tmp/nginx_signing.rsa.pub https://nginx.org/keys/nginx_signing.rsa.pub && \
    mv /tmp/nginx_signing.rsa.pub /etc/apk/keys/

RUN apk add --no-cache \
    bash git net-tools openssl openrc nginx \
    npm nodejs make gcc g++ python && \
    npm install --force -g log.io --user "root" && \
    npm cache clean --force && \
    apk del make gcc g++ python && \
    rm -rf /tmp/* /var/cache/apk/* /root/.npm /root/.node-gyp

COPY . /app
COPY ./harvester.conf /root/.log.io/harvester.conf
COPY ./nginx.conf /etc/nginx/nginx.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf

EXPOSE 80 28778
CMD ["nginx", "log.io-server"]
