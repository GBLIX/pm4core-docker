FROM processmaker/pm4-base:2.1.7

RUN apt update && apt install -y php8.1-dev php-pear librdkafka-dev
RUN pecl install rdkafka
RUN echo "extension=rdkafka.so" > /etc/php/8.1/cli/conf.d/rdkafka.ini

ARG PM_VERSION

WORKDIR /tmp
RUN wget https://github.com/ProcessMaker/processmaker/archive/refs/tags/v${PM_VERSION}.zip
RUN unzip v${PM_VERSION}.zip && rm -rf /code/pm4 && mv processmaker-${PM_VERSION} /code/pm4

WORKDIR /code/pm4
RUN composer install
COPY build-files/laravel-echo-server.json .
RUN npm install --unsafe-perm=true && npm run dev

COPY build-files/laravel-echo-server.json .
COPY build-files/init.sh .
CMD bash init.sh && supervisord --nodaemon
