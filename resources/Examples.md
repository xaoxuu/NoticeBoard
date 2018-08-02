# ![](https://raw.githubusercontent.com/xaoxuu/NoticeBoard/master/resources/header.png)

<hr>

## 文档

在线文档在这里：[https://xaoxuu.com/docs/noticeboard](https://xaoxuu.com/docs/noticeboard)

<br>

## 示例

下面这些例子可以**【直接点击】**查看效果的哦

<br>

#### 快速post

<br>



**[👉 post一条消息，内容为"Hello World!"](cmd://fastpost:1)**

```swift
NoticeBoard.post("Hello World!")
```
<br>

**[👉 post一条消息，内容为"Hello World!"，2秒后消失](cmd://fastpost:2)**

```swift
NoticeBoard.post("Hello World!", duration: 2)
```
<br>

**[👉 post一条指定主题样式的消息](cmd://fastpost:11)**

```swift
NoticeBoard.post(.error, message: "Something Happend", duration: 5)
```
<br>

**[👉 post一条指定主题样式的消息](cmd://fastpost:12)**

```swift
NoticeBoard.post(.dark, message: "Good evening", duration: 2)
```
<br>

**[👉 post一条指定主题样式并且带标题的消息](cmd://fastpost:21)**

```swift
NoticeBoard.post(.light, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
```
<br>

**[👉 post一条指定主题样式并且带标题和icon的消息](cmd://fastpost:31)**

```swift
let img = UIImage.init(named: "alert-circle")
NoticeBoard.post(.light, icon:img, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
```
<br>

**[👉 右边的按钮“→”](cmd://fastpost:41)**

```swift
// duration参数为0代表无穷大，即不自动消失。
NoticeBoard.post(.warning, icon: img, title: "Warning", message: "Please see more info", duration: 0) { (notice, sender) in
    NoticeBoard.post("button tapped", duration: 1)
}
```

<br>



#### post进度

设置任意一条 `notice` 实例的 `progress` 属性，即时生效。

```swift
// 进度为0
notice.progress = 0
// 进度为50%
notice.progress = 0.5
// 进度为100%
notice.progress = 1
```

测试：[0%](cmd://postpro:0) | [20%](cmd://postpro:20) | [50%](cmd://postpro:50) | [70%](cmd://postpro:70) | [100%](cmd://postpro:100) | [自动](cmd://postpro:1000)



## 帮助

如果你还不明白如何使用，或者发现BUG，或者有更好的建议，都欢迎👏来提 [**issue**](https://github.com/xaoxuu/NoticeBoard/issues) 。



<hr>

Powered by [xaoxuu](https://xaoxuu.com)

<br><br><br><br>