#include "redismodule.h"
#include <stdlib.h>
#include <string.h>

int UnsignedDecr_RedisCommand(RedisModuleCtx *ctx, RedisModuleString **argv,
                              int argc) {
  if (argc != 2) {
    return RedisModule_WrongArity(ctx);
  }

  RedisModuleKey *key;
  key = RedisModule_OpenKey(ctx, argv[1], REDISMODULE_READ | REDISMODULE_WRITE);
  if (RedisModule_KeyType(key) != REDISMODULE_KEYTYPE_STRING &&
      RedisModule_KeyType(key) != REDISMODULE_KEYTYPE_EMPTY) {
    RedisModule_CloseKey(key);
    return RedisModule_ReplyWithError(ctx, REDISMODULE_ERRORMSG_WRONGTYPE);
  }

  if (RedisModule_KeyType(key) == REDISMODULE_KEYTYPE_EMPTY) {
    RedisModule_CloseKey(key);
    return RedisModule_ReplyWithNull(ctx);
  }

  size_t len;
  char *keyValuePtr = RedisModule_StringDMA(key, &len, REDISMODULE_WRITE);
  int keyValue = atoi(keyValuePtr);

  if (keyValue == 0) {
    RedisModule_CloseKey(key);
    RedisModule_ReplyWithLongLong(ctx, 0);
    return REDISMODULE_OK;
  }

  // Decrement the key from direct memory access pointer
  char *str = RedisModule_Alloc(len);
  keyValue--;
  // If the key was modified outside of this module, clamp the value to 0.
  if (keyValue < 0) {
    keyValue = 0;
  }

  sprintf(str, "%d", keyValue);
  *keyValuePtr = *str;

  // Key memory allocation size is always the same as the original key, we
  // truncate here to save the space when decrementing from large values.
  RedisModule_StringTruncate(key, strlen(str));

  // Safe to free here given we've copied the temp string back into the
  // original.
  RedisModule_Free(str);

  RedisModule_CloseKey(key);
  RedisModule_ReplyWithLongLong(ctx, keyValue);

  return REDISMODULE_OK;
}

int RedisModule_OnLoad(RedisModuleCtx *ctx, RedisModuleString **argv,
                       int argc) {
  if (RedisModule_Init(ctx, "unsigned.decr", 1, REDISMODULE_APIVER_1) ==
      REDISMODULE_ERR)
    return REDISMODULE_ERR;

  if (RedisModule_CreateCommand(ctx, "unsigned.decr", UnsignedDecr_RedisCommand,
                                "write deny-oom", 1, 1, 1) == REDISMODULE_ERR)
    return REDISMODULE_ERR;

  return REDISMODULE_OK;
}
