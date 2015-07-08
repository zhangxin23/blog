---
layout: post
title: "Linux的crontab应注意事项"
description: "Linux的crontab应注意事项"
category: Linux
tags: [Linux, crontab]
---

今天遇到一个问题，困扰了好久，刚开始时以为crontab定时任务配置错误，后经过验证没有错误，然后又怀疑到是不是权限问题呀？将权限跟改为root后，重新配置crontab定时任务，还是不行，真是让人气馁。后来想到在脚本中通过“set -x”命令打开脚本调试信息并重定向到一个文件中，后查看输出文件，发现JAVA_HOME没有设置，不对呀，我明明在.bashrc文件中配置了JAVA_HOME呀，这是怎么回事，难道是crontab的运行环境变量和我的环境变量不一样，抱着试一试的想法，我将JAVA_HOME配置成固定值，不用从PATH环境变量中读取，然后再用crontab定时任务执行这个脚本，哈哈，居然成功，总算找到问题的原因啦！现总结如下：

	1 crontab有自己特定的运行环境变量，可能和手动运行脚本的环境变量不一样；

	2 可在脚本的开始处，用“set -x”命令开启调试信息，可输出脚本运行的信息，在脚本的结束处，用“set +x”关闭调试信息；