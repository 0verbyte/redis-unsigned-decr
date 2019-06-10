FROM gcc:9.1

WORKDIR /tmp/build/

COPY redismodule.h .
COPY unsigned_decr.c .
COPY Makefile .

RUN make object-code
RUN make shared-lib

FROM redis:5.0

COPY redis.conf /usr/local/etc/redis/redis.conf
COPY --from=0 /tmp/build/unsigned_decr.so /usr/local/etc/redis/unsigned_decr.so

CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]