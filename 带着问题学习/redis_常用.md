##### 1.访问 Redis 中的海量数据

 错误使用：

```
 keys user*

keys算法是遍历算法，复杂度是O(n)，也就是数据越多，时间复杂度越高。 当数据量很大时，会导致单线程的redis阻塞，影响正常业务。
```

正确方法： 

```
SCAN cursor [MATCH pattern] [COUNT count]
scan 游标 MATCH <返回和给定模式相匹配的元素> count redis单次遍历字典槽位数量(约等于)

例如：scan 0 match user_token* count 5

SCAN命令是增量的循环，每次调用只会返回一小部分的元素。所以不会让redis假死
SCAN命令返回的是一个游标，从0开始遍历，到0结束遍历
```

