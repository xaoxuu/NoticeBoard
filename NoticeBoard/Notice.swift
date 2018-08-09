//
//  Notice.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/20.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit


// MARK: - 定义
public extension Notice {
    /// 当notice被移除时的通知
    public static let didRemoved = NSNotification.Name.init("noticeDidRemoved")
    
    /// 主题
    public enum Theme: String {
        
        case success = "#7CC353"
        case warning = "#FFEB3B"
        case error   = "#F44336"
        
        case note = "FFBD2D"
        case normal  = "#52A1F8"
        
        case lightGray = "#ECECEC"
        case darkGray = "#555"
        case white = "#FFF"
        case plain = "#00000000"
        
        public var color: UIColor {
            if self == .plain {
                return .clear
            } else {
                return UIColor.init(hex: self.rawValue)
            }
        }
        
    }
    public struct NoticeAlertOptions : OptionSet {
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        // MARK: 以什么样的速度
        /// 正常速度，默认
        public static var normally: NoticeAlertOptions {
            return self.init(rawValue: 1 << 10)
        }
        
        /// 缓慢地
        public static var slowly: NoticeAlertOptions {
            return self.init(rawValue: 1 << 11)
        }
        
        /// 快速地
        public static var fast: NoticeAlertOptions {
            return self.init(rawValue: 1 << 12)
        }
        
        // MARK: 做什么样的动作
        /// 颜色变深，默认
        public static var darken: NoticeAlertOptions {
            return self.init(rawValue: 1 << 20)
        }
        
        /// 颜色变浅
        public static var lighten: NoticeAlertOptions {
            return self.init(rawValue: 1 << 21)
        }
        
        /// 闪烁（alpha: 1 -> 0）
        public static var flash: NoticeAlertOptions {
            return self.init(rawValue: 1 << 22)
        }
        
        // MARK: 重复多少次
        /// 一次，默认
        public static var once: NoticeAlertOptions {
            return self.init(rawValue: 1 << 30)
        }
        
        /// 两次
        public static var twice: NoticeAlertOptions {
            return self.init(rawValue: 1 << 31)
        }
        
        /// 呼吸灯效果
        public static var breathing: NoticeAlertOptions {
            return self.init(rawValue: 1 << 32)
        }
        
    }
    
}


// MARK: - Notice: 一条通知的视图实体。
open class Notice: UIWindow {
    
    // MARK: - public property
    
    /// 正文最大高度
    public var bodyMaxHeight = CGFloat(180) {
        didSet {
            updateContentFrame()
        }
    }
    
    /// 可通过手势移除通知
    public var allowRemoveByGesture = true
    
    /// 主题（改变背景颜色）
    public var themeColor = UIColor.clear {
        didSet {
            rootViewController?.view.backgroundColor = themeColor
            tintColor = themeColor.textColor()
        }
    }
    
    /// 主题（改变背景颜色）
    public var theme = Theme.plain {
        didSet {
            themeColor = theme.color
        }
    }
    
    /// 模糊效果
    public var blurEffectStyle: UIBlurEffectStyle? {
        didSet {
            if let blur = blurEffectStyle {
                // FIXME: 在iOS11之前的系统上模糊效果变成半透明，暂时不知道为什么
                if #available(iOS 11.0, *) {
                    if self.visualEffectView == nil {
                        let vev = UIVisualEffectView.init(frame: self.bounds)
                        vev.effect = UIBlurEffect.init(style: blur)
                        if blur == UIBlurEffectStyle.dark {
                            tintColor = .white
                        } else {
                            tintColor = .black
                        }
                        vev.layer.masksToBounds = true
                        self.rootViewController?.view.insertSubview(vev, at: 0)
                        if let pro = progressLayer {
                            vev.layer.addSublayer(pro)
                        }
                        self.visualEffectView = vev
                    }
                } else {
                    if blur == .dark {
                        theme = .darkGray
                    } else {
                        theme = .white
                    }
                }
            }
        }
    }
    
    // MARK: subviews
    
    public var iconView : UIImageView?
    public var titleLabel: UILabel?
    
    public var bodyView: UITextView?
    public var visualEffectView: UIVisualEffectView?
    public var dragButton: UIButton?
    public var actionButton: UIButton?
    public var progressLayer: CALayer?
    
    
    // MARK: model
    public var title: String {
        get {
            if let t = titleLabel?.text {
                return t
            } else {
                return ""
            }
        }
        set {
            self.rootViewController?.view.addSubview(loadTitleLabel())
            
            var animated = false
            if let t = titleLabel?.text {
                if t.count > 0 {
                    animated = true
                }
            }
            titleLabel?.text = newValue
            titleLabel?.textColor = tintColor
            
            actionButton?.setTitleColor(tintColor, for: .normal)
            updateContentFrame()
            
            if animated {
                UIView.animate(withDuration: 0.38, animations: {
                    self.updateSelfFrame()
                })
            } else {
                self.updateSelfFrame()
            }
        }
    }
    public var body: String {
        get {
            if let t = bodyView?.text {
                return t
            } else {
                return ""
            }
        }
        set {
            self.rootViewController?.view.addSubview(loadTextView())
            var animated = false
            if let t = bodyView?.text {
                if t.count > 0 {
                    animated = true
                }
            }
            bodyView?.text = newValue
            bodyView?.textColor = tintColor
            updateContentFrame()
            
            
            if animated {
                UIView.animate(withDuration: 0.38, animations: {
                    self.updateSelfFrame()
                }) { (completed) in
                    if let btn = self.dragButton {
                        btn.alpha = 1
                    }
                }
            } else {
                self.updateSelfFrame()
            }
            loadProgressLayer()
        }
    }
    
    public var icon: UIImage? {
        get {
            return iconView?.image
        }
        set {
            if let i = newValue {
                let v = loadIconView()
                v.image = i
                v.tintColor = tintColor
                if let _ = titleLabel {
                    self.rootViewController?.view.addSubview(v)
                } else {
                    v.removeFromSuperview()
                }
                updateContentFrame()
            }
        }
    }
    public var progress = CGFloat(0) {
        didSet {
            loadProgressLayer()
            if let _ = progressLayer {
                if var f = self.rootViewController?.view.bounds {
                    f.size.width = progress * f.size.width
                    self.progressLayer?.frame = f
                }
            }
        }
    }
    
    public var level = NoticeBoard.Level.normal {
        didSet {
            windowLevel = level.rawValue
        }
    }
    
    // MARK: - internal property
    // life cycle
    
    /// 持续的时间，0表示无穷大
    internal var duration = TimeInterval(0)
    
    /// 过期自动消失的函数
    internal var workItem : DispatchWorkItem?
    
    // action
    internal var block_action: ((Notice, UIButton)->Void)?
    internal weak var board = NoticeBoard.shared
    // layout
    internal var lastFrame = CGRect.zero
    internal var originY = margin {
        didSet {
            var f = self.frame
            f.origin.y = originY
            self.frame = f
        }
    }
    
    // MARK: - override property
    open override var frame: CGRect {
        didSet {
            updateSelfFrame()
            if board?.layoutStyle == .tile {
                if frame.size.height != lastFrame.size.height {
                    debugPrint("update frame")
                    lastFrame = frame
                    if let index = board?.notices.index(of: self) {
                        board?.updateLayout(from: index)
                    }
                }
            }
        }
    }
    
    open override func setNeedsLayout() {
        var f = self.frame
        f.size.width = min(UIScreen.main.bounds.size.width - 2 * margin, maxWidth)
        f.origin.x = (UIScreen.main.bounds.size.width - f.size.width) / 2
        self.frame = f
        
        if let t = actionButton {
            t.frame = frame(for: .actionButton)
        }
        if let t = bodyView {
            t.frame = frame(for: .bodyView)
        }
        if let t = dragButton {
            t.frame = frame(for: .dragButton)
        }
        updateContentFrame()
    }
    
    // MARK: - public func
    
    /// 警示（如果一个notice已经post出来了，想要再次引起用户注意，可以使用此函数）
    ///
    /// - Parameter options: 操作
    public func alert(options: NoticeAlertOptions = []){
        func animation(_ animation: CABasicAnimation) {
            animation.autoreverses = true
            animation.isRemovedOnCompletion = true
            animation.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
            // default
            // normally
            animation.duration = 0.8
            // darken
            animation.toValue = self.rootViewController?.view.backgroundColor?.darken(0.3).cgColor
            // once
            animation.repeatCount = 1
            
            if options.contains(.fast) {
                animation.duration = 0.38
            } else if options.contains(.slowly) {
                animation.duration = 2.4
            }
            if options.contains(.flash) {
                animation.toValue = UIColor.init(white: 1, alpha: 0).cgColor
            } else if options.contains(.lighten) {
                animation.toValue = self.rootViewController?.view.backgroundColor?.lighten(0.7).cgColor
            }
            if options.contains(.breathing) {
                animation.repeatCount = MAXFLOAT
            } else if options.contains(.twice) {
                animation.repeatCount = 2
            }
            
        }
        let ani = CABasicAnimation.init(keyPath: "backgroundColor")
        animation(ani)
        self.rootViewController?.view.layer.add(ani, forKey: "backgroundColor")
        
    }
    
    /// "→"按钮的事件
    ///
    /// - Parameter action: "→"按钮的事件
    open func actionButtonDidTapped(action: @escaping(Notice, UIButton) -> Void){
        self.rootViewController?.view.addSubview(loadActionButton())
        updateContentFrame()
        block_action = action
    }
    
    open func removeFromNoticeBoard(){
        board?.remove(self, animate: .slide)
    }
    // MARK: - private func
    
    
    // MARK: - life cycle
    public convenience init(title: String?, icon: UIImage?, body: String?) {
        self.init()
        
        func text(_ text: String?) -> String? {
            if let t = text {
                if t.count > 0 {
                    return t
                } else {
                    return nil
                }
            } else {
                return nil
            }
        }
        
        if let text = text(title) {
            self.title = text
        }
        if let image = icon {
            self.icon = image
        }
        if let text = text(body) {
            self.body = text
        }
        
    }
    
    public convenience init(theme: Theme) {
        self.init()
        DispatchQueue.main.async {
            self.theme = theme
        }
    }

    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        windowLevel = level.rawValue
        
        layer.shadowRadius = 12
        layer.shadowOffset = .init(width: 0, height: 8)
        layer.shadowOpacity = 0.35
        
        let vc = UIViewController()
        self.rootViewController = vc
        vc.view.frame = self.bounds
        vc.view.layer.cornerRadius = cornerRadius
        vc.view.clipsToBounds = true
        
        loadActionButton()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(_:)))
        self.addGestureRecognizer(pan)
        
    }
    
    convenience init() {
        let width = min(UIScreen.main.bounds.size.width - 2 * margin, maxWidth)
        let marginX = (UIScreen.main.bounds.size.width - width) / 2
        let preferredFrame = CGRect.init(x: marginX, y: margin, width: width, height: titleHeight)
        self.init(frame: preferredFrame)
    }
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    open override var tintColor: UIColor!{
        didSet {
            iconView?.tintColor = tintColor
            titleLabel?.textColor = tintColor
            bodyView?.textColor = tintColor
            actionButton?.setTitleColor(tintColor, for: .normal)
            dragButton?.setTitleColor(tintColor, for: .normal)
        }
    }
    deinit {
        debugPrint("👌🏼deinit")
    }
    
    
}

// MARK: - action
internal extension Notice {
    
    @objc func touchDown(_ sender: UIButton) {
        debugPrint("touchDown: " + (sender.titleLabel?.text)!)
        if sender.tag == Tag.dragButton.rawValue {
            sender.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        } else if sender.tag == Tag.actionButton.rawValue {
            
        }
    }
    @objc func touchUp(_ sender: UIButton) {
        debugPrint("touchUp: " + (sender.titleLabel?.text)!)
        if sender.tag == Tag.dragButton.rawValue {
            sender.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        } else if sender.tag == Tag.actionButton.rawValue {
            
        }
    }
    @objc func touchUpInside(_ sender: UIButton) {
        touchUp(sender)
        debugPrint("touchUpInside: " + (sender.titleLabel?.text)!)
        if sender == actionButton {
            block_action?(self, sender)
        }
        
    }
    @objc func pan(_ sender: UIPanGestureRecognizer) {
        DispatchWorkItem.cancel(self.workItem)
        let point = sender.translation(in: sender.view)
        var f = self.frame
        f.origin.y += point.y
        self.frame = f
        sender.setTranslation(.zero, in: sender.view)
        if sender.state == .recognized {
            let v = sender.velocity(in: sender.view)
            if allowRemoveByGesture == true && ((frame.origin.y + point.y < 0 && v.y < 0) || v.y < -1200) {
                board?.remove(self, animate: .slide)
            } else {
                if let btn = self.dragButton {
                    self.touchUp(btn)
                }
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    var f = self.frame
                    f.origin.y = self.originY
                    self.frame = f
                }) { (completed) in
                    if self.duration > 0 {
                        self.board?.post(self, duration: self.duration)
                    }
                    
                }
            }
        }
        
    }
    
    internal func translate(_ animateStyle: NoticeBoard.AnimationStyle, _ buildInOut: NoticeBoard.BuildInOut){
        switch animateStyle {
        case .slide:
            move(buildInOut)
        case .fade:
            fade(buildInOut)
        }
    }
    
    internal func move(_ animate: NoticeBoard.BuildInOut){
        switch animate {
        case .buildIn:
            transform = .identity
        case .buildOut:
            if transform == .identity {
                let offset = frame.size.height + frame.origin.y + layer.shadowRadius + layer.shadowOffset.height
                transform = .init(translationX: 0, y: -offset)
            }
        }
    }
    
    internal func fade(_ animate: NoticeBoard.BuildInOut){
        switch animate {
        case .buildIn:
            self.alpha = 1
        case .buildOut:
            self.alpha = 0
        }
    }
}

