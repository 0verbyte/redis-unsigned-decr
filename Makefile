object-code:
	gcc -c -Wall -Werror -fpic unsigned_decr.c

shared-lib:
	gcc -shared -o unsigned_decr.so unsigned_decr.o

docker:
	docker build -t redis-local:local .

docker-run:
	docker run -itp 6379:6379 redis-local:local

.PHONY: docker docker-run