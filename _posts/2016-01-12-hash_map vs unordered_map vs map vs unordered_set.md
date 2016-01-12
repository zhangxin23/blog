---
layout: post
title: "hash_map vs unordered_map vs map vs unordered_set"
description: "hash_map vs unordered_map vs map vs unordered_set"
category: C++
tags: [C++]
---

###hash_map vs unordered_map

这两个的内部结构都是采用哈希表来实现。unordered_map在C++11的时候被引入标准库了，而hash_map没有，所以建议还是使用unordered_map比较好。

###unordered_map vs map

map的内部结构是R-B-tree来实现的，所以保证了一个稳定的动态操作时间，查询、插入、删除都是O(logN)，最坏和平均情况都是；而unordered_map是哈希表。虽然哈希表的查询时间是O(1)，但是并不是unordered_map查询时间一定比map短，因为实际情况中还要考虑到数据量，而且unordered_map的hash函数的构造速度也没那么快，所以不能一概而论，应该具体情况具体分析。

###unordered_map vs unordered_set

unordered_set就是在哈希表插入value，而这个value就是它自己的key。
