

**Increase stack space**

Sometimes you can see people suggest [increasing the stack space](https://unix.stackexchange.com/a/45584/85039) with `ulimit -s `; on Linux ARG_MAX value is 1/4th of stack space for each program, which means increasing stack space proportionally increases space for arguments.

```
# getconf reports value in bytes, ulimit -s in kilobytes
$ getconf ARG_MAX
2097152
$ echo $((  $(getconf ARG_MAX)*4 ))
8388608
$ printf "%dK\n" $(ulimit -s) | numfmt --from=iec --to=none
8388608
# Increasing stack space results in increated ARG_MAX value
$ ulimit -s 16384
$ getconf ARG_MAX
4194304
```

According to [answer by Franck Dernoncourt](https://unix.stackexchange.com/a/245762/85039), which cites Linux Journal, one can also recompile Linux kernel with larger value for maximum memory pages for arguments, however, that's more work than necessary and opens potential for exploits as stated in the cited Linux Journal article.