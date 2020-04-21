##### 1. hashCode方法？

在未重写类hashCode方法时，JDK默认使用Object类native的hashCode方法，据说该方法直接返回对象的内存地址

String类型的hashCode方法：
/**
* 返回此字符串的哈希码。字符串对象的哈希码计算为 s[0]*31^(n-1) + s[1]*31^(n-2) + ... + s[n-1]，其中s [i]是字符串的字符，n是字符串的长度，^表示幂。
*/

  ```java
  public int hashCode() {
     int h = hash;
   if (h == 0 && value.length > 0) {
         char val[] = value;
         
     for (int i = 0; i < value.length; i++) {
         h = 31 * h + val[i];
     }
     hash = h;

   }
	   return h;
	 }
	```
	
	其中val例如其为{k, e, y} 则有 
	0 = 'k' 107
	1 = 'e' 101
	2 = 'y' 121
	
	------
	
	

##### 2. hash 算法的实现原理（为什么右移 16 位，为什么要使用 ^ 位异或）

/**
*计算key.hashCode（）并将哈希的较高位（XOR）扩展为较低。 因为该表使用2的幂次掩码，所以仅在当前掩码上方的位中变化的哈希集将始终发生冲突。 
（众所周知的示例是在小表中包含连续整数的Float键集。）因此，我们应用了一种变换，将向下传播较高位的影响。 在速度，实用性和位扩展质量之间需要权衡。
由于许多常见的哈希集已经合理分布（因此无法从扩展中受益），并且由于我们使用树来处理容器中的大量冲突集，因此我们仅以最便宜的方式对一些移位后的位进行XOR，
以减少系统损失， 以及合并最高位的影响，否则由于表范围的限制，这些位将永远不会在索引计算中使用。
*/

```java
static final int hash(Object key) {
     int h;
     return (key == null) ? 0 : (h = key.hashCode()) ^ (h >>> 16);
 }
```

get方法：tab[(n - 1) & hash]  
如： n = 16 , hash值如下：
A 1000010001110001000001111000000
B 0111011100111000101000010100000
则这些低位相同的数据将会一直发生冲突，即仅在当前掩码上方的位中变化的哈希集将始终发生冲突，其中冲突最多的就是包含连续整数的Float键集，
所以在计算其Hash值时向下传播高位的影响，以减少哈希冲突。在使用红黑树处理容器中的大量冲突集后，这种移位运算应该算是较为适宜的了吧。

##### 3. 为什么大部分 hashcode 方法使用 31？

《Effective Java》中也对其进行了说明：
之所以使用 31， 是因为他是一个奇素数。如果乘数是偶数，并且乘法溢出的话，信息就会丢失，因为与2相乘等价于移位运算（低位补0）。
使用素数的好处并不很明显，但是习惯上使用素数来计算散列结果。31 有个很好的性能，即用移位和减法来代替乘法，可以得到更好的性能： 
31 * i == (i << 5）- i， 现代的 VM 可以自动完成这种优化。所以我们能知道的就是使用 31 最主要的还是为了性能。

------



##### 4. HashMap什么时候会进行 rehash？

HashMap的默认负载因子是DEFAULT_LOAD_FACTOR = 0.75，即当HashMap的节点数大于[0.75*initialCapacity]（阈值） 时就会进行扩容操作。[default initial capacity (16) and the default load factor (0.75)]
如果没有给HashMap设置初始大小时，会默认设置大小为16。扩容时，默认是扩容2倍，则每一个元素在新数组中的位置要么是原来的index，要么index = index + oldCap。
当执行put方法时，会执行以下判断，threshold为其阈值，例如默认initialCapacity=16时，插入第13个数时便会进行rehash,并根据e.hash & (newCap - 1)重新分配对应元素的位置

```java
if (++size > threshold)
	resize();
```

​	

​	

JDK1.7中,在多线程情况下rehash时可能会出现环形链表，导致死循环。在1.8中不再调用transfer方法，并将该方法写在自己的方法体内，来处理死循环，并保证了扩容后，新数组中的链表顺序依然与旧数组中的链表顺序保持一致！
//如果扩容后，元素的index依然与原来一样，那么使用这个head和tail指针
Node<K,V> loHead = null, loTail = null;
//如果扩容后，元素的index=index+oldCap，那么使用这个head和tail指针

```java
Node<K,V> hiHead = null, hiTail = null;
Node<K,V> next;
do {
	next = e.next;
	

	//这个地方直接通过hash值与oldCap进行与操作得出元素在新数组的index，为0则不变，为1则需要加上oldCap
	if ((e.hash & oldCap) == 0) {
		if (loTail == null)
			loHead = e;
		else
			//tail指针往后移动一位，维持顺序
			loTail.next = e;
		loTail = e;
	}
	else {
		if (hiTail == null)
			hiHead = e;
		else
			//tail指针往后移动一位，维持顺序 
			hiTail.next = e;
		hiTail = e;
	}

} while ((e = next) != null);
if (loTail != null) {
	loTail.next = null;
	//index = index
	newTab[j] = loHead;
}
if (hiTail != null) {
	hiTail.next = null;
	//index = index + oldCap
	newTab[j + oldCap] = hiHead;
}
```

当发生hash碰撞时，会判断链表个数是否大于等于TREEIFY_THRESHOLD[默认为8],如果满足则会将链表结构转换为红黑树，则其时间复杂度由O(n)--> O(log(n)),查找时的总时间复杂度为O(1)+O(n) --> O(1)+O(log(n))
链表长度达到8就转成红黑树，当长度降到6就转成普通bin。

```java
if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
     treeifyBin(tab, hash);
```

------

 `HashMap`的线程不安全主要体现在下面两个方面：
1.在JDK1.7中，当并发执行扩容操作时会造成环形链和数据丢失的情况。
2.在JDK1.8中，在并发执行put操作时会发生数据覆盖的情况。 

##### 5. HashMap和 HashTable有何不同？

HashTable:
底层数组+链表实现，无论key还是value都不能为null，线程安全，实现线程安全的方式是在修改数据时锁住整个HashTable，效率低，ConcurrentHashMap做了相关优化
初始size为11，扩容：newsize = olesize*2+1
计算index的方法：index = (hash & 0x7FFFFFFF) % tab.length

HashMap:
底层数组+链表实现，可以存储null键和null值，线程不安全
初始size为16，扩容：newsize = oldsize*2，size一定为2的n次幂
扩容针对整个Map，每次扩容时，原来数组中的元素依次重新计算存放位置，并重新插入
插入元素后才判断该不该扩容，有可能无效扩容（插入后如果扩容，如果没有再次插入，就会产生无效扩容）
当Map中元素总数超过Entry数组的75%，触发扩容操作，为了减少链表长度，元素分配更均匀
计算index方法：index = hash & (tab.length – 1)

###### HashTable： 

 [*default initial capacity (11) and load factor (0.75)*.]

​	public synchronized V put(K key, V value){...}
​	public synchronized V get(Object key) {...}
​	public synchronized V remove(Object key) {...}
​	index = (hash & 0x7FFFFFFF) % tab.length; [0x7FFFFFFF = 111,1111,1111,1111,1111,1111,1111,1111] hash与其按位与得到一个正数为什么不用Math.abs呢 因为当这个hash被计算出来是一个最小负数-2^31 ，正整数中没有32位去表示这个最小负数，所以还是会返回一个负数 ，也就是说绝对值函数返回的还是一个负数。java中的int类型存储长度为32bit，符号位占了1个bit ，所以可以用来表示int的数目的范围是31位。但是int的范围是“-2^31”到“2^31-1”;

```
newCapacity = (oldCapacity << 1) + 1;
	int hash = key.hashCode();
```

###### HashMap: 

```
index = (n - 1) & hash;
	hash = key.hashCode() ^ (h >>> 16);
```


HashTable和HashMap在执行get、put、remove等方法时都会取hash值并使用equals判断是否相同，不同的是HashTable为保证线程安全在对应方法上都添加了synchronized关键字

------



##### 6. java中集合类的理解，项目中用过哪些，哪个地方用的，如何使用的

```
java.util.AbstractCollection<E> (implements java.util.Collection<E>) 
	java.util.AbstractList<E> (implements java.util.List<E>) 
		java.util.AbstractSequentialList<E> 
			java.util.LinkedList<E> (implements java.lang.Cloneable, java.util.Deque<E>, java.util.List<E>, java.io.Serializable) 
		java.util.ArrayList<E> (implements java.lang.Cloneable, java.util.List<E>, java.util.RandomAccess, java.io.Serializable) 
		java.util.Vector<E> (implements java.lang.Cloneable, java.util.List<E>, java.util.RandomAccess, java.io.Serializable) 
			java.util.Stack<E> 
	java.util.AbstractQueue<E> (implements java.util.Queue<E>) 
		java.util.PriorityQueue<E> (implements java.io.Serializable) 
	java.util.AbstractSet<E> (implements java.util.Set<E>) 
		java.util.EnumSet<E> (implements java.lang.Cloneable, java.io.Serializable) 
		java.util.HashSet<E> (implements java.lang.Cloneable, java.io.Serializable, java.util.Set<E>) 
			java.util.LinkedHashSet<E> (implements java.lang.Cloneable, java.io.Serializable, java.util.Set<E>) 
		java.util.TreeSet<E> (implements java.lang.Cloneable, java.util.NavigableSet<E>, java.io.Serializable) 
	java.util.ArrayDeque<E> (implements java.lang.Cloneable, java.util.Deque<E>, java.io.Serializable) 
java.util.AbstractMap<K,V> (implements java.util.Map<K,V>) 
	java.util.EnumMap<K,V> (implements java.lang.Cloneable, java.io.Serializable) 
		java.util.HashMap<K,V> (implements java.lang.Cloneable, java.util.Map<K,V>, java.io.Serializable) 
			java.util.LinkedHashMap<K,V> (implements java.util.Map<K,V>) 
		java.util.IdentityHashMap<K,V> (implements java.lang.Cloneable, java.util.Map<K,V>, java.io.Serializable) 
		java.util.TreeMap<K,V> (implements java.lang.Cloneable, java.util.NavigableMap<K,V>, java.io.Serializable) 
		java.util.WeakHashMap<K,V> (implements java.util.Map<K,V>) 
```

​		

###### IdentityHashMap： 

DEFAULT_CAPACITY = 32 [ table = new Object[2 * initCapacity] ]

​	get方法揭示了其存储结构，使用数组来存储元素，tab[i]为其Key，tab[i+1]为其value

```
while (true) {
		Object item = tab[i];
		if (item == k)
			return (V) tab[i + 1];
		if (item == null)
			return null;
		i = nextKeyIndex(i, len);
	}
```



###### WeakHashMap： 

​	WeakHashMap扩容时是在添加完第threshold个元素时

###### TreeMap: 

​	采用红黑树实现；put方法每次新加元素后，都要调用fixAfterInsertion重新维持红黑树的平衡

------



##### 7. HashMap 和 ConcurrentHashMap 的区别？  

从类图中可以看出来在存储结构中ConcurrentHashMap比HashMap多出了一个类Segment，而Segment是一个可重入锁。

ConcurrentHashMap是使用了锁分段技术来保证线程安全的。

锁分段技术：首先将数据分成一段一段的存储，然后给每一段数据配一把锁，当一个线程占用锁访问其中一个段数据的时候，其他段的数据也能被其他线程访问。 

ConcurrentHashMap提供了与Hashtable和SynchronizedMap不同的锁机制。Hashtable中采用的锁机制是一次锁住整个hash表，从而在同一时刻只能由一个线程对其进行操作；而ConcurrentHashMap中则是一次锁住一个桶。

ConcurrentHashMap默认将hash表分为16个桶，诸如get、put、remove等常用操作只锁住当前需要用到的桶。这样，原来只能一个线程进入，现在却能同时有16个写线程执行，并发性能的提升是显而易见的。

##### 8. 结合源码说说 HashMap在高并发场景中为什么会出现死循环？ 

当多线程情况下，假如线程一执行至Entry<K,V> next = e.next后挂起;然后线程二开始执行，链表转移时会进行倒置，头连接链表，则有A-->B-->null   ==>  B-->A-->null,线程二执行完毕。
线程一重新开始执行，则会有e=A , next=B; 当执行e=next后，则会有e=B,而现在B-->A，则会出现B-->A-->B的情况，从而产生死循环。
在1.8中不再调用transfer方法，并将该方法写在自己的方法体内，来处理死循环，并保证了扩容后，新数组中的链表顺序依然与旧数组中的链表顺序保持一致！[通过使用index不同时的tmp来处理的]

jdk1.7的reszie:

```java
void transfer(Entry[] newTable){
 Entry[] src = table;
 int newCapacity = newTable.length;
 //下面这段代码的意思是：
 //  从OldTable里摘一个元素出来，然后放到NewTable中
 for (int j = 0; j < src.length; j++) {
     Entry<K,V> e = src[j];
     if (e != null) {
            src[j] = null;
            do {
                Entry<K,V> next = e.next;
                int i = indexFor(e.hash, newCapacity);
                e.next = newTable[i];
                newTable[i] = e;
                e = next;
            } while (e != null);
        }
    }
}
```



------



##### 9. 为什么ConcurrentHashMap中的链表转红黑树的阀值是8？

当链表结构转换为红黑树，则其时间复杂度由O(n)--> O(log(n)),查找时的总时间复杂度为O(1)+O(n) --> O(1)+O(log(n))
链表长度达到8就转成红黑树，当长度降到6就转成普通bin。应该是通过时间和空间的权衡决定的，TreeNodes占用空间是普通Nodes的两倍，所以只有当bin包含足够多的节点时才会转成TreeNodes。
通过源码中的注释可知：
	当hashCode离散性很好的时候，树型bin用到的概率非常小，因为数据均匀分布在每个bin中，几乎不会有bin中链表长度会达到阈值。但是在随机hashCode下，离散性可能会变差，
然而JDK又不能阻止用户实现这种不好的hash算法，因此就可能导致不均匀的数据分布。不过理想情况下随机hashCode算法下所有bin中节点的分布频率会遵循泊松分布，我们可以看到，
一个bin中链表长度达到8个元素的概率为0.00000006，几乎是不可能事件。

```
if (binCount >= TREEIFY_THRESHOLD - 1) // -1 for 1st
     treeifyBin(tab, hash);
```



##### 10. BitSet 位图？

BitSet是位操作的对象，值只有0或1即false和true，内部维护了一个long数组，初始只有一个long，所以BitSet最小的size是64，当随着存储的元素越来越多，BitSet内部会动态扩充，最终内部是由N个long来存储，这些针对操作都是透明的。

用1位来表示一个数据是否出现过，0为没有出现过，1表示出现过。使用的时候可根据某一个是否为0表示，此数是否出现过。

一个1G的空间，有 8*1024*1024*1024=8.58*10^9bit，也就是可以表示85亿个不同的数

使用场景：

	常见的应用是那些需要对海量数据进行一些统计工作的时候，比如日志分析、用户数统计等等
	
	如统计40亿个数据中没有出现的数据，将40亿个不同数据进行排序等。
	现在有1千万个随机数，随机数的范围在1到1亿之间。现在要求写出一种算法，将1到1亿之间没有在随机数中的数求出来

数亿的用户，如何统计独立用户访问量？
拼多多有数亿的用户，那么对于某个网页，怎么使用Redis来统计一个网站的用户访问数呢？
###### 使用Hash
###### 使用Bitset
###### 使用概率算法