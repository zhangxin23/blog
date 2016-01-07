---
layout: post
title: "Http Header Content-Disposition"
description: "Http Header Content-Disposition"
category: http
tags: [http]
---

###Content-Disposition用途

Content-Disposition是为了实现服务器下载文件功能，并可提供文件名。

###Content-Disposition格式

	content-disposition = "Content-Disposition" ":"disposition-type *( ";" disposition-parm )

		disposition-type = "attachment" | disp-extension-token
		disposition-parm = filename-parm | disp-extension-parm
		filename-parm = "filename" "=" quoted-string
		disp-extension-token = token
		disp-extension-parm = token "=" ( token | quoted-string )

例子：

	Content-Disposition: attachment; filename="fname.ext"

一般当Content-Type为text、pdf等常见类型时，浏览器会直接打开。如果不想在浏览器内打开文件，可将Content-Type设置为octet-stream二进制类型，浏览器会弹出保存对话框。

###注意事项

1 Http Header各项必须是ASCII编码，所以文件名不能有中文字符。

2 Content-Disposition不是http的标准，并不是所有浏览器都兼容，要注意兼容性问题。