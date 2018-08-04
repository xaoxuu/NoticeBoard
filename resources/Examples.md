# ![](https://raw.githubusercontent.com/xaoxuu/NoticeBoard/master/resources/header.png)

<hr>

## 文档

[👉 在线文档](https://xaoxuu.com/docs/noticeboard)

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

<br>

#### post自定义的view

<br>

**[👉 示例1](cmd://postcustom:1)**

```swift
let h = w * 0.25
notice.blurEffectStyle = .extraLight
let view = UIView.init(frame: .init(x: 0, y: 0, width: w, height: h))
let ww = view.width * 0.7
let hh = CGFloat(h)
let imgv = UIImageView.init(frame: .init(x: (w-ww)/2, y: (h-hh)/2, width: ww, height: hh))
imgv.image = UIImage.init(named: "header_center")
imgv.contentMode = .scaleAspectFit
view.addSubview(imgv)
notice.rootViewController?.view.addSubview(view)
notice.actionButtonDidTapped(action: { (notice, sender) in
    if let url = URL.init(string: "https://xaoxuu.com/docs/noticeboard") {
        UIApplication.shared.openURL(url)
    }
})
notice.actionButton?.setTitle("→", for: .normal)
```

<br>

**[👉 示例2](cmd://postcustom:2)**

```swift
let h = w * 0.6
let view = UIView.init(frame: .init(x: 0, y: 0, width: w, height: h))
notice.rootViewController?.view.addSubview(view)
web.frame = .init(x: 0, y: -44, width: w, height: h+44)
view.addSubview(web)
// icon
let icon = UIImageView.init(frame: .init(x: w/2 - 30, y: h/2 - 16 - 30, width: 60, height: 60))
icon.image = UIImage.init(named: Bundle.appIconName())
icon.contentMode = .scaleAspectFit
icon.layer.masksToBounds = true
icon.layer.cornerRadius = 15
view.addSubview(icon)
// label
let lb = UILabel.init(frame: .init(x: 0, y: icon.frame.maxY + 8, width: w, height: 20))
lb.textAlignment = .center
lb.font = UIFont.boldSystemFont(ofSize: 14)
lb.textColor = .white
lb.text = "\(Bundle.init(for: NoticeBoard.self).bundleName()!) \(Bundle.init(for: NoticeBoard.self).bundleShortVersionString()!)"
view.addSubview(lb)
// button
notice.actionButtonDidTapped(action: { (notice, sender) in
    UIView.animate(withDuration: 0.68, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
        if sender.transform == .identity {
            sender.transform = CGAffineTransform.init(rotationAngle: CGFloat.pi / 4 * 3)
        } else {
            sender.transform = .identity
        }
    }, completion: nil)
})
notice.actionButton?.setTitle("＋", for: .normal)
notice.actionButton?.setTitleColor(.white, for: .normal)
```

<br>

<br>

## 帮助

如果你还不明白如何使用，或者发现BUG，或者有更好的建议，都欢迎👏来提 [**issue**](https://github.com/xaoxuu/NoticeBoard/issues) 。

<br>

<hr>

Powered by [xaoxuu](https://xaoxuu.com)

<br><br><br><br><br>