//
//  DebuggerWindow.swift
//  Example
//
//  Created by xaoxuu on 2018/6/28.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import NoticeBoard

let isIPhoneX: Bool = {
    if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) || UIScreen.main.bounds.size.equalTo(CGSize.init(width: 812, height: 375)) {
        return true
    } else {
        return false
    }
}()
func topSafeMargin() -> CGFloat {
    if isIPhoneX {
        return 44;
    } else {
        return margin;
    }
}
func bottomSafeMargin() -> CGFloat {
    if isIPhoneX {
        return 34 + margin;
    } else {
        return margin;
    }
}


let margin = CGFloat(8)
let padding = CGFloat(4)
let minH = CGFloat(100)
let titleH = CGFloat(36)
let cellH = CGFloat(40)
let screenSize = UIScreen.main.bounds.size

let defSize = CGSize.init(width: screenSize.width - 2 * margin, height: screenSize.height - topSafeMargin() - bottomSafeMargin())
let collapsePoint = CGPoint.init(x: margin, y: screenSize.height - minH)
let expandPoint = CGPoint.init(x: margin, y: topSafeMargin())

let collapseFrame = CGRect.init(origin: collapsePoint, size: defSize)
let expandFrame = CGRect.init(origin: expandPoint, size: defSize)


class DebuggerWindow: UIWindow,UITextViewDelegate {

    enum Tag: Int {
        typealias RawValue = Int
        
        case bg = 10
        case clean = 11
        case post = 12
        
        case title = 20
        case body = 21
        case icon = 22
        
        case duration = 30
        case color = 31
        case blur = 32
        case level = 33
        case layout = 34
        
        var cacheKey : String {
            switch self {
            case .bg:
                return "cache.bg"
            case .clean:
                return "cache.clean"
            case .post:
                return "cache.post"
            case .title:
                return "cache.title"
            case .body:
                return "cache.body"
            case .icon:
                return "cache.icon"
            case .duration:
                return "cache.duration"
            case .color:
                return "cache.color"
            case .blur:
                return "cache.blur"
            case .level:
                return "cache.level"
            case .layout:
                return "cache.layout"
                
                
            }
        }
    }
    
    var lastFrame = collapseFrame
    lazy var tf_title = loadTextField(placeholder: "notice title", text: "notice title")
    lazy var tv_body = loadTextView()
    lazy var lb_duration = loadLabel(text: "0s")
    lazy var s_duration = loadSlider(min: 0, max: 60)

    lazy var seg_icon = UISegmentedControl.init()
    lazy var seg_color = UISegmentedControl.init()
    lazy var seg_blur = UISegmentedControl.init()
    lazy var seg_level = UISegmentedControl.init()
    lazy var seg_layout = UISegmentedControl.init()
    
    // MARK: - life cycle
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.layer.borderWidth = 1
        windowExpand()
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
        textView.layer.borderWidth = 0
        windowResume()
        UserDefaults.standard.set(textView.text, forKey: Tag.body.cacheKey)
    }
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        windowLevel = 9000
        makeKeyAndVisible()
        tintColor = .white
        layer.masksToBounds = true
        layer.cornerRadius = 12
        let vev = UIVisualEffectView.init(frame: .init(origin: .zero, size: defSize))
        vev.effect = UIBlurEffect.init(style: .dark)
        addSubview(vev)
        
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(_:)))
        self.addGestureRecognizer(pan)
        transform = .init(translationX: 0, y: minH)
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.allowUserInteraction,.curveEaseOut], animations: {
            self.transform = .identity
        }) { (completed) in
            
        }
        
        // first install
        let notFirstLaunch = UserDefaults.standard.bool(forKey: "notFirstLaunch")
        if !notFirstLaunch {
            UserDefaults.standard.set(true, forKey: "notFirstLaunch")
            UserDefaults.standard.set("this is title", forKey: Tag.title.cacheKey)
            UserDefaults.standard.set("this is body", forKey: Tag.body.cacheKey)
            UserDefaults.standard.set(1, forKey: Tag.icon.cacheKey)
            UserDefaults.standard.set(2, forKey: Tag.duration.cacheKey)
            UserDefaults.standard.set(1, forKey: Tag.color.cacheKey)
            UserDefaults.standard.set(1, forKey: Tag.level.cacheKey)
        }
        
        // subviews
        
        let lb_title = loadLabel(text: "NoticeBoard Debugger")
        lb_title.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
        lb_title.textAlignment = .center
        lb_title.font = UIFont.boldSystemFont(ofSize: 15)
        addSubview(lb_title)
        var f = lb_title.frame
        
        
        let btn_remove = loadButton(title: "clean")
        f.origin.x = margin
        f.origin.y += f.size.height + margin
        f.size.width = (defSize.width - 4 * margin) / 3
        f.size.height = cellH
        btn_remove.frame = f
        addSubview(btn_remove)
        f = btn_remove.frame
        
        let btn_progress = loadButton(title: "progress")
        f.origin.x += f.size.width + margin
        btn_progress.frame = f
        addSubview(btn_progress)
        f = btn_progress.frame
        
        let btn_post = loadButton(title: "post")
        f.origin.x += f.size.width + margin
        btn_post.frame = f
        addSubview(btn_post)
        f = btn_post.frame
        
        // title
        f.origin.x = margin
        f.origin.y += f.size.height + margin
        f.size.width = defSize.width - 2 * margin
        tf_title.frame = f
        tf_title.layer.borderColor = UIColor.white.cgColor
        addSubview(tf_title)
        tf_title.tag = Tag.title.rawValue
        tf_title.text = UserDefaults.standard.string(forKey: Tag.title.cacheKey)
        f = tf_title.frame
        
        // body
        f.origin.y += f.size.height + margin
        f.size.height = 80
        tv_body.frame = f
        tv_body.tag = Tag.body.rawValue
        tv_body.text = UserDefaults.standard.string(forKey: Tag.body.cacheKey)
        tv_body.layer.borderColor = UIColor.white.cgColor
        addSubview(tv_body)
        f = tv_body.frame
        
        
        // icon
        f.origin.y += f.size.height + margin
        seg_icon = loadSegment(y: f.origin.y, title: "icon", items: ["none","alert-circle"], tag: Tag.icon.rawValue)
        seg_icon.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.icon.cacheKey)
        addSubview(seg_icon)
        f = seg_icon.frame
        
        // duration
        f.origin.y += f.size.height + margin
        f.origin.x = margin
        f.size.width = 50
        lb_duration.frame = f
        addSubview(lb_duration)
        
        // duration
        f.origin.x += f.size.width + margin
        f.size.width = defSize.width - 3 * margin - f.size.width
        s_duration.frame = f
        addSubview(s_duration)
        f = s_duration.frame
        
        // color
        f.origin.y += f.size.height + margin
        f.origin.x = margin
        seg_color = loadSegment(y: f.origin.y, title: "color", items: ["clear", "normal", "warning", "error"], tag: Tag.color.rawValue)
        seg_color.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.color.cacheKey)
        addSubview(seg_color)
        
        
        // blur
        f.origin.y += f.size.height + margin
        seg_blur = loadSegment(y: f.origin.y, title: "blur", items: ["none", "light", "extraLight", "dark"], tag: Tag.blur.rawValue)
        seg_blur.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.blur.cacheKey)
        addSubview(seg_blur)
        
        
        
        // level
        f.origin.y += f.size.height + margin
        seg_level = loadSegment(y: f.origin.y, title: "level", items: ["low", "normal", "high"], tag: Tag.level.rawValue)
        seg_level.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.level.cacheKey)
        addSubview(seg_level)
        
        
        // layout
        f.origin.y += f.size.height + margin
        seg_layout = loadSegment(y: f.origin.y, title: "layout", items: ["tile", "replace", "remove", "stack"], tag: Tag.layout.rawValue)
        seg_layout.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.layout.cacheKey)
        addSubview(seg_layout)
        
        
        
        // footer
        f.origin.y += f.size.height + margin
        f.size = .init(width: defSize.width - 2*margin, height: 24)
        let lb_footer = loadLabel(text: "@xaoxuu")
        lb_footer.font = UIFont.systemFont(ofSize: 12)
        lb_footer.textAlignment = .right
        lb_footer.frame = f
        addSubview(lb_footer)
        
        
        var ff = self.frame
        ff.size.height = f.maxY + margin
        self.frame = ff
        
    }
    convenience init() {
        self.init(frame: collapseFrame)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func windowExpand() {
        lastFrame = frame
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            var f = self.frame
            f.origin = expandPoint
            self.frame = f
        }) { (completed) in
            
        }
    }
    func windowCollapse() {
        lastFrame = frame
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            var f = self.frame
            f.origin = collapsePoint
            self.frame = f
        }) { (completed) in
            
        }
    }
    func windowResume() {
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
            self.frame = self.lastFrame
        }) { (completed) in
            
        }
    }
    
    
}



extension DebuggerWindow{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.endEditing(true)
    }
    func loadLabel(text: String?) -> UILabel {
        let lb = UILabel.init(frame: .init(x: 0, y: 0, width: defSize.width, height: titleH))
        lb.textColor = .white
        lb.textAlignment = .justified
        lb.text = text
        return lb
    }
    
    func loadSlider(min: Float, max: Float) -> UISlider{
        let s = UISlider.init(frame: .init(x: 0, y: 0, width: defSize.width, height: cellH))
        s.minimumValue = min
        s.maximumValue = max
        let value = UserDefaults.standard.integer(forKey: Tag.duration.cacheKey)
        s.value = Float(value)
        if value > 0 {
            lb_duration.text = "\(value)s"
        } else {
            lb_duration.text = "∞"
        }
        s.addTarget(self, action: #selector(self.sliderChanged(_:)), for: .valueChanged)
        return s
    }
    func loadTextField(placeholder: String?, text: String?) -> UITextField {
        let tf = UITextField.init(frame: .init(x: 0, y: 0, width: defSize.width, height: cellH))
        tf.borderStyle = .roundedRect
        tf.layer.cornerRadius = 4
        tf.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
        tf.returnKeyType = .done
        tf.textColor = .white
        tf.placeholder = placeholder
        tf.text = text
        tf.addTarget(self, action: #selector(self.tfInputBegin(_:)), for: .editingDidBegin)
        tf.addTarget(self, action: #selector(self.tfInputEnd(_:)), for: [.editingDidEnd, .editingDidEndOnExit])
        return tf
    }
    func loadTextView() -> UITextView {
        let tv = UITextView.init(frame: .init(x: 0, y: 0, width: defSize.width, height: 100))
        tv.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
        tv.layer.cornerRadius = 4
        tv.textColor = .white
        tv.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        tv.delegate = self
        return tv
    }
    func loadSegment(items: [String], tag: Int) -> UISegmentedControl{
        let seg = UISegmentedControl.init(items: items)
        seg.tag = tag
        seg.frame = CGRect.init(x: margin, y: margin, width: 0.5*defSize.width, height: cellH)
        seg.selectedSegmentIndex = UserDefaults.standard.integer(forKey: Tag.bg.cacheKey)
        seg.addTarget(self, action: #selector(self.segmentChanged(_:)), for: .valueChanged)
        return seg
    }
    func loadSegment(y: CGFloat, title: String, items: [String], tag: Int) -> UISegmentedControl{
        // title
        var f = CGRect.init(x: margin, y: y, width: 50, height: cellH)
        let lb = loadLabel(text: title)
        lb.frame = f
        addSubview(lb)
        f = lb.frame
        
        f.origin.x += f.size.width + margin
        f.size.width = defSize.width - 3 * margin - f.size.width
        
        let seg = loadSegment(items: items, tag: tag)
        seg.frame = f
        addSubview(seg)
        return seg
    }
    
    func loadButton(title: String?) -> UIButton {
        let btn = UIButton.init(frame: .init(x: 0, y: 0, width: defSize.width, height: cellH))
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 4
        btn.setTitle(title, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
        btn.addTarget(self, action: #selector(self.tapBtn(_:)), for: .touchUpInside)
        btn.addTarget(self, action: #selector(self.btnUp(_:)), for: [.touchUpInside, .touchUpOutside, .touchCancel])
        btn.addTarget(self, action: #selector(self.btnDown(_:)), for: .touchDown)
        btnUp(btn)
        return btn
    }
    func loadButton(title: String?, normal: String?, selected: String?) -> UIButton{
        let btn = UIButton.init(frame: .init(x: 0, y: 0, width: defSize.width, height: cellH))
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle(title, for: .normal)
        if let t  = title {
            if let n = normal {
                btn.setTitle(t + ": " + n, for: .normal)
                if let s = selected {
                    btn.setTitle(t + ": " + s, for: .selected)
                }
            } else {
                btn.setTitle(t, for: .normal)
            }
        }
        btn.addTarget(self, action: #selector(self.selectBtn(_:)), for: .touchUpInside)
        return btn
    }
    
    @objc func sliderChanged(_ sender: UISlider) {
        let value = Int(sender.value)
        UserDefaults.standard.set(value, forKey: Tag.duration.cacheKey)
        if value > 0 {
            lb_duration.text = "\(value)s"
        } else {
            lb_duration.text = "∞"
        }
    }
    @objc func segmentChanged(_ sender: UISegmentedControl) {
        if sender.tag == Tag.bg.rawValue {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: Tag.bg.cacheKey)
        } else if sender.tag == Tag.icon.rawValue {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: Tag.icon.cacheKey)
        } else if sender.tag == Tag.color.rawValue {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: Tag.color.cacheKey)
        } else if sender.tag == Tag.blur.rawValue {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: Tag.blur.cacheKey)
        } else if sender.tag == Tag.level.rawValue {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: Tag.level.cacheKey)
        } else if sender.tag == Tag.layout.rawValue {
            UserDefaults.standard.set(sender.selectedSegmentIndex, forKey: Tag.layout.cacheKey)
        }
    }
    @objc func tfInputBegin(_ sender: UITextField) {
        windowExpand()
        sender.layer.borderWidth = 1
    }
    @objc func tfInputEnd(_ sender: UITextField) {
        sender.resignFirstResponder()
        windowResume()
        sender.layer.borderWidth = 0
        UserDefaults.standard.set(sender.text, forKey: Tag.title.cacheKey)
    }
    
    @objc func tapBtn(_ sender: UIButton) {
        if let t = sender.titleLabel?.text {
            if t == "post" || t == "progress" {
                let n = Notice.init(title: tf_title.text, icon: nil, body: tv_body.text)
                if let iconName = seg_icon.titleForSegment(at: seg_icon.selectedSegmentIndex) {
                    if let i = UIImage.init(named: iconName) {
                        n.icon = i
                    }
                }
                
                let duration = TimeInterval(s_duration.value)
                
                setTheme(notice: n, seg: seg_color)
                setTheme(notice: n, seg: seg_blur)
                
                func level(index: Int) -> NoticeBoard.Level {
                    if index == 0 {
                        return NoticeBoard.Level.low
                    } else if index == 1 {
                        return NoticeBoard.Level.normal
                    } else if index == 2 {
                        return NoticeBoard.Level.high
                    }
                    return NoticeBoard.Level.normal
                }
                n.level = level(index: seg_level.selectedSegmentIndex)
                
                func layout(index: Int) -> NoticeBoard.LayoutStyle {
                    if index == 0 {
                        return NoticeBoard.LayoutStyle.tile
                    } else if index == 1 {
                        return NoticeBoard.LayoutStyle.replace
                    } else if index == 2 {
                        return NoticeBoard.LayoutStyle.remove
                    } else if index == 3 {
                        return NoticeBoard.LayoutStyle.stack
                    }
                    return NoticeBoard.LayoutStyle.tile
                }
                if t == "progress" {
                    updateProgress(notice: n, pro: 0)
                }
                
                NoticeBoard.post(n, duration: duration, layout: layout(index: seg_layout.selectedSegmentIndex))
               
                n.setAction { (notice, sender) in
                    notice.body = notice.body + "\n\(Date.init().description(with: Locale.current)) 点击了→"
                }
                
            } else if t == "clean" {
                NoticeBoard.clean()
            }
            
        }
    }
    @objc func selectBtn(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @objc func btnDown(_ sender: UIButton) {
        sender.backgroundColor = UIColor.init(white: 1, alpha: 0.3)
    }
    @objc func btnUp(_ sender: UIButton) {
        sender.backgroundColor = UIColor.init(white: 1, alpha: 0.1)
    }
    
    @objc func pan(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.translation(in: sender.view)
        var f = self.frame
        f.origin.y += point.y
        self.frame = f
        sender.setTranslation(.zero, in: sender.view)
        if sender.state == .began {
            self.endEditing(true)
        }
        if sender.state == .recognized {
            let velocity = sender.velocity(in: sender.view)
            var endF = f
            if abs(velocity.y) > 50 {
                endF.origin.y += 0.3 * velocity.y
            }

            var duration = 1.5
            if abs(velocity.y) > 4000 {
                duration = 0.3
            } else if abs(velocity.y) > 2000 {
                duration = 0.5
            } else if abs(velocity.y) > 1000 {
                duration = 1
            }
            UIView.animate(withDuration: duration, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: [.allowUserInteraction, .curveEaseOut], animations: {
                var endY = endF.origin.y
                if endY + f.size.height + bottomSafeMargin() < UIScreen.main.bounds.height {
                    endY = UIScreen.main.bounds.height - f.size.height - bottomSafeMargin()
                }
                if endY < expandPoint.y {
                    endY = expandPoint.y
                } else if endY > collapsePoint.y {
                    endY = collapsePoint.y
                } else {

                }
                endF.origin.y = endY
                self.frame = endF
            }) { (completed) in

            }

        }

    }
    
    
    
    @objc func updateProgress(notice: Notice, pro: CGFloat){
        notice.progress = pro
        notice.title = "已完成：\(Int(pro*100))%\n"
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            if pro <= 1 {
                self.updateProgress(notice: notice, pro: pro + 0.02)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    NoticeBoard.remove(notice)
                }
            }
        }
    }
}

extension DebuggerWindow {
    func setTheme(notice: Notice, seg: UISegmentedControl){
        let selectedSegmentIndex = seg.selectedSegmentIndex
        if seg == seg_color {
            if selectedSegmentIndex == 1 {
                notice.set(theme: .normal)
            } else if selectedSegmentIndex == 2 {
                notice.set(theme: .warning)
            } else if selectedSegmentIndex == 3 {
                notice.set(theme: .error)
            }
        } else if seg == seg_blur {
            if selectedSegmentIndex == 1 {
                notice.set(theme: .light)
            } else if selectedSegmentIndex == 2 {
                notice.set(theme: .extraLight)
            } else if selectedSegmentIndex == 3 {
                notice.set(theme: .dark)
            }
        }
    }
    
}
