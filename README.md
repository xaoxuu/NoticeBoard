# ![](https://raw.githubusercontent.com/xaoxuu/NoticeBoard/master/resources/header.png)

[![](https://img.shields.io/badge/license-MIT-green.svg?style=flat)](https://raw.githubusercontent.com/xaoxuu/NoticeBoard/master/LICENSE)  [![](https://img.shields.io/badge/platform-iOS%208%2B%20-orange.svg?style=flat)](https://www.apple.com/nl/ios/)  [![](https://img.shields.io/cocoapods/v/NoticeBoard.svg?style=flat)](https://cocoapods.org/pods/NoticeBoard)  [![](https://img.shields.io/cocoapods/dt/NoticeBoard.svg)](https://codeload.github.com/xaoxuu/NoticeBoard/zip/master)  [![](https://img.shields.io/cocoapods/at/NoticeBoard.svg)](https://cocoapods.org/pods/NoticeBoard) 



一个适用于iOS平台的简单易用的应用内消息通知框架。

| screenshot                                                   | video                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| ![](https://user-images.githubusercontent.com/16400144/43441330-10b44176-94cd-11e8-8a1e-d0870273e537.PNG) | <video id="video" controls="" preload="none"  poster="https://user-images.githubusercontent.com/16400144/43441330-10b44176-94cd-11e8-8a1e-d0870273e537.PNG" width=100%>  <source id="mp4" src="http://pcpw4brqf.bkt.clouddn.com/noticeboard0731.MP4" type="video/mp4"></video> |



### 导入

```ruby
pod 'NoticeBoard'
```

### 使用

```swift
// 创建notice
let notice = Notice.init(title: "标题", icon: UIImage.init(named: "alert-"), body: "正文")
// 发布notice       
NoticeBoard.shared.post(notice, duration: 2)
// 移除某个通知
NoticeBoard.shared.remove(notice)
// 清空
NoticeBoard.shared.clean()
```

> NoticeBoard中的func均提供了同名的class func，等同于NoticeBoard.shared。

个性化设置

```swift
// 按钮事件
notice.actionButtonDidTapped { (notice, btn) in
    print("点击了'→'按钮")
}

// 设置颜色主题
notice.themeColor = .init(red: 0.2, green: 0.3, blue: 0.4, alpha: 1)
// 模糊背景（暂时只支持iOS11，在之前的系统会自动改为纯色背景），和纯色背景可以同时使用
notice.blurEffectStyle = .light
```



### 快速post

```swift
// post一条消息，内容为"Hello World!"
NoticeBoard.post("Hello World!")
NoticeBoard.post("Hello World!", duration: 2)

// post一条指定主题样式的消息
NoticeBoard.post(.error, message: "Something Happend", duration: 5)
NoticeBoard.post(.dark, message: "Good evening", duration: 2)

// post一条指定主题样式并且带标题的消息
NoticeBoard.post(.light, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)

// post一条指定主题样式并且带标题和icon的消息
let img = UIImage.init(named: "alert-circle")
NoticeBoard.post(.light, icon:img, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)

// 对于带有标题的消息，可以设置右边的按钮“→”
NoticeBoard.post(.warning, icon: img, title: "Warning", message: "Please see more info", duration: 0) { (notice, sender) in
    NoticeBoard.post("button tapped", duration: 1)
}
```

> duration参数为0代表无穷大，即不自动消失。
>
> 返回值为notice实例，可以随时更改notice。



### post进度

设置任意一条 `notice` 实例的 `progress` 属性，即时生效。

```swift
// 进度为0
notice.progress = 0
// 进度为50%
notice.progress = 0.5
// 进度为100%
notice.progress = 1
```



### post自定义view

```swift
notice.rootViewController?.view.addSubview(myView)
NoticeBoard.post(notice)
```



### 多个通知的布局

如果同一时间需要存在多个通知，可以根据使用场景选择不同的布局方式：

```swift
// 平铺，默认（所有通知都可见，但是通知过多会超出屏幕）
NoticeBoard.shared.layoutStyle = .tile
NoticeBoard.shared.post(notice, duration: 2)

// 取代旧的通知（旧的采用fade动画淡出）
NoticeBoard.shared.layoutStyle = .replace
NoticeBoard.shared.post(notice, duration: 2)

// 移除旧的通知（旧的采用moveout动画移出屏幕）
NoticeBoard.shared.layoutStyle = .remove
NoticeBoard.shared.post(notice, duration: 2)

// 覆盖在旧的通知上层（切勿堆积过多）
NoticeBoard.shared.layoutStyle = .overlay
NoticeBoard.shared.post(notice, duration: 2)

// 堆叠（最新的通知会遮挡旧的通知）
NoticeBoard.shared.layoutStyle = .stack
NoticeBoard.shared.post(notice, duration: 2)
```



### 设置Level

默认提供了四种level：

```swift
// case low = 4000
// case normal = 4100
// case high = 4200
// case veryHigh = 4300
notice.level = .normal
```

也可以直接设置任意数值：

```swift
notice.windowLevel = 1000
```



### 在Swift和Objective-C中使用

`NoticeBoard`使用`Swift4.1`语言编写，如需在`Objective-C`项目中使用，可以采用`Objective-C`和`Swift`混编的方式，详情请参照示例程序：`Example-OC`。