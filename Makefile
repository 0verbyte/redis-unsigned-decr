object-code:
	gcc -c -Wall -Werror -fpic unsigned_decr.c

shared-lib:
	gcc -shared -o unsigned_decr.so unsigned_decr.o

docker:
	docker build -t redis-local:local .

docker-run:
	docker run -itp 6379:6379 redis-local:local

test:
	redis-cli --eval unsigned_decr_test.lua && redis-cli flushall

lua-debugger:
	redis-cli --ldb --eval unsigned_decr_test.lua

.PHONY: object-code shared-lib docker docker-run test lua-debugger
