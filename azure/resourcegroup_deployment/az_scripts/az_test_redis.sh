
#!/usr/bin/env bash

REDIS_AUTHKEY=$arg1
REDIS_HOST_FULL=$arg2
RESULT=`(printf "AUTH $REDIS_AUTHKEY\r\nPING\r\nQUIT\r\n") | nc $REDIS_HOST_FULL 6379 | grep PONG`
[ "$RESULT" != "" ] && ( echo "Redis instance at $REDIS_HOST_FULL is working!" ) || ( echo "Redis istance at $REDIS_HOST_FULL has problems!" )
