1. ##### 系统不可用
	
	代码中某个位置读取数据量较大，导致系统内存耗尽，从而导致 Full GC 次数过多，系统缓慢。
	代码中有比较耗 CPU 的操作，导致 CPU 过高，系统运行缓慢。
	
2. ##### 功能缓慢，但不至于不可用

	代码某个位置有阻塞性的操作，导致该功能调用整体比较耗时，但出现是比较随机的。
	某个线程由于某种原因而进入 WAITING 状态，此时该功能整体不可用，但是无法复现。
	由于锁使用不当，导致多个线程进入死锁状态，从而导致系统整体比较缓慢。
	
3. ##### 常见情况
	
	Full GC 次数过多
	CPU 过高
	不定期出现的接口耗时现象
	某个线程进入 WAITING 状态
	死锁
	
4. ##### 基本思路：

简要的说，我们进行线上日志分析时，主要可以分为如下步骤：

①通过 top 命令查看 CPU 情况，如果 CPU 比较高，则通过 top -Hp 命令查看当前进程的各个线程运行情况。

找出 CPU 过高的线程之后，将其线程 id 转换为十六进制的表现形式，然后在 jstack 日志中查看该线程主要在进行的工作。

这里又分为两种情况：

如果是正常的用户线程，则通过该线程的堆栈信息查看其具体是在哪处用户代码处运行比较消耗 CPU。
如果该线程是 VM Thread，则通过 jstat -gcutil pid 命令监控当前系统的 GC 状况。
然后通过 jmap dump:format=b,file=order.dump pid  导出系统当前的内存数据。( 会暂停应用， 线上系统慎用 )

导出之后将内存情况放到 Eclipse 的 Mat 工具中进行分析即可得出内存中主要是什么对象比较消耗内存，进而可以处理相关代码。

②如果通过 top 命令看到 CPU 并不高，并且系统内存占用率也比较低。此时就可以考虑是否是由于另外三种情况导致的问题。

具体的可以根据具体情况分析：

如果是接口调用比较耗时，并且是不定时出现，则可以通过压测的方式加大阻塞点出现的频率，从而通过 jstack 查看堆栈信息，找到阻塞点。

如果是某个功能突然出现停滞的状况，这种情况也无法复现，此时可以通过多次导出 jstack 日志的方式对比哪些用户线程是一直都处于等待状态，这些线程就是可能存在问题的线程。

如果通过 jstack 可以查看到死锁状态，则可以检查产生死锁的两个线程的具体阻塞点，从而处理相应的问题。

本文主要是提出了五种常见的导致线上功能缓慢的问题，以及排查思路。当然，线上的问题出现的形式是多种多样的，也不一定局限于这几种情况。

#### gstat 命令

- 类加载统计：jstat  -class 10664
- 编译统计：jstat -compiler 10664
- 垃圾回收统计：jstat -gc 10664
- 堆内存统计：jstat -gccapacity 10664
- 新生代垃圾回收统计：jstat -gcnew 10664
- 新生代内存统计：jstat -gcnewcapacity 10664
- 老年代垃圾回收统计：jstat -gcold 10664
- 老年代内存统计：jstat -gcoldcapacity 10664
- 元数据空间统计：jstat -gcmetacapacity 10664
- 总结垃圾回收统计：jstat -gcutil 10664
- JVM编译方法统计：jstat -printcompilation 10664

#### jmap 命令

-  查看进程的内存映像信息 ：jmap pid
-  显示Java堆详细信息 : jmap -heap pid
-  显示堆中对象的统计信息 : jmap -histo:live pid
-  打印类加载器信息 : jmap -clstats pid
-  打印等待终结的对象信息 : jmap -finalizerinfo pid
-  生成堆转储快照dump文件：jmap -dump:format=b,file=heapdump.phrof pid



#### 问题场景

1. ##### JVM 堆内存溢出后，其他线程是否可继续工作？

   ###### jvm中的内存溢出又分为很多种：

   -  堆溢出（“java.lang.OutOfMemoryError: Java heap space”） 
   -  方法区溢出（“java.lang.OutOfMemoryError:Permgen space”） 
   -  栈溢出,不能创建线程（“java.lang.OutOfMemoryError:Unable to create new native thread”） 
   - 直接内存溢出（“OutOfMemoryError”）

   ###### 产生原因：

   - 堆中存在大量对象无法被gc回收，可能是内存泄漏或者大对象过多
   - 方法区存放类信息，当class越来越多时就会产生此问题
   - 创建的线程多到栈不足以支撑时
   - 分配过多内存给运行时数据区，导致直接内存使用到时不足

   ###### 解决方法：

   - 优化代码， 或使用 -Xms -Xmx等参数调整堆的大小 
   -  使用-XX:PermSize参数调整方法区的大小 
   -  使用-Xss参数调整栈的大小
   - 使用-XX：MaxDirectMemorySize属性指定直接内存的大小 

   综上所述，要根据不同情况来看。例如出现堆溢出时，则在报出OOM错误前一定进行了大量的gc，则会对所有线程都产生影响。当OOM时，则该线程会被jvm终结掉，则其所占有的资源都会被释放出来。

   ###### 总结：

   ​	**当堆栈等发生溢出时，其他线程依旧能够进行工作**，但是频繁的gc可能会对其他的线程产生无法预知的影响。

   ###### 测试结果：

   ​	![](E:\study_doc\syudy_doc\带着问题学习\test_result_pic\thread_oom.jpg)

   堆大小为：-Xms16m -Xmx32m   线程数量2

   ![](E:\study_doc\syudy_doc\带着问题学习\test_result_pic\head.png)

   ![](E:\study_doc\syudy_doc\带着问题学习\test_result_pic\thread_dead.jpg)

   当Thread-0报错OOM时，线程数量实时线程数量减一，堆空间释放

2. 