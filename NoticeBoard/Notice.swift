//
//  Notice.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/20.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit

internal let margin = CGFloat(8)
internal let padding10 = CGFloat(8)
internal let padding4 = CGFloat(4)

internal let cornerRadius = CGFloat(12)
internal let titleHeight = CGFloat(36)
internal let dragButtonHeight = CGFloat(24)

internal let defaultInset = UIEdgeInsets.init(top: padding10, left: padding4, bottom: padding10, right: padding4)


internal func topSafeMargin() -> CGFloat {
    if NoticeBoard.isIPhoneX {
        return 30 + 10;
    } else {
        return margin;
    }
}


internal func visible(_ view: UIView?) -> UIView?{
    if let v = view {
        if v.superview != nil && !v.isHidden {
            return v
        } else {
            return nil
        }
    } else {
        return nil
    }
}
internal func visible(_ view: UITextView?) -> UITextView?{
    if let v = view {
        if v.superview != nil && !v.isHidden {
            return v
        } else {
            return nil
        }
    } else {
        return nil
    }
}

private enum Tag: Int {
    typealias RawValue = Int
    
    case iconView = 101
    case titleView = 102
    case actionButton = 103
    case bodyView = 201
    case dragButton = 301
    
}

// MARK: - frame
internal extension Notice {
    
    func updateSelfFrame(){
        var totalHeight = CGFloat(0)
        for view in self.contentView.subviews {
            if view.isEqual(contentView) == false && view.isEqual(visualEffectView) == false {
                totalHeight = max(totalHeight, view.frame.maxY)
            }
        }
        
        self.contentView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: totalHeight)
        self.visualEffectView?.frame = self.contentView.bounds
        if let p = progressLayer {
            var f = p.frame
            f.size.height = totalHeight
            p.frame = f
        }
        if self.frame.height != totalHeight {
            var f = self.frame
            f.size.height = totalHeight
            self.frame = f
        }
    }
    
    func updateContentFrame(){
        if let t1 = visible(titleLabel){
            var f = t1.frame
            if let t0 = visible(iconView) {
                if self.subviews.contains(t0) == false {
                    self.contentView.addSubview(t0)
                }
                f.origin.x = t0.frame.maxX + padding4
            }
            f.size.width = self.frame.size.width - f.origin.x - padding10
            if let v = visible(actionButton) {
                f.size.width -= v.frame.size.width
            }
            t1.frame = f
        }
        if let t1 = visible(bodyView) {
            var f = t1.frame
            if let t0 = visible(titleLabel) {
                f.origin.y = t0.frame.maxY
                bodyView?.textContainerInset.top = 0
            } else {
                bodyView?.textContainerInset = defaultInset
            }
            f.size.height = max(bodyMaxHeight, 0)
            t1.frame = f
            f.size.height = min(t1.contentSize.height, max(bodyMaxHeight, 0))
            UIView.animate(withDuration: 0.38) {
                t1.frame = f
            }
            
            if t1.contentSize.height > f.size.height {
                self.contentView.addSubview(loadDragButton())
                if let btn = visible(dragButton) {
                    var ff = btn.frame
                    ff.origin.y = t1.frame.maxY
                    btn.frame = ff
                    btn.alpha = 1
                }
            } else {
                if let btn = visible(dragButton) {
                    btn.alpha = 0
                    btn.removeFromSuperview()
                }
            }
        }
    }
    
}

@objcMembers
open class Notice: UIWindow {

    /// 当notice被移除时的通知
    public static let didRemoved = NSNotification.Name.init("noticeDidRemoved")
    
    public enum Theme {
        public typealias RawValue = UIColor
        case success, note, warning, error, normal
        var rawValue : RawValue {
            var color = UIColor.white
            switch self {
            case .success:
                color = UIColor.ax_green
            case .note:
                color = UIColor.ax_blue
            case .warning:
                color = UIColor.ax_yellow
            case .error:
                color = UIColor.ax_red
            default:
                color = UIColor.ax_blue
            }
            return color
        }
        init () {
            self = .normal
        }

    }
    public struct NoticeAlertOptions : OptionSet {
        public var rawValue: UInt
        
        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }
        
        /// 一次
        public static var once: NoticeAlertOptions {
            return self.init(rawValue: 1 << 0)
        }
        
        /// 两次
        public static var twice: NoticeAlertOptions {
            return self.init(rawValue: 1 << 1)
        }
        
        /// 呼吸灯效果
        public static var breathing: NoticeAlertOptions {
            return self.init(rawValue: 1 << 2)
        }
        
        /// 正常速度
        public static var normally: NoticeAlertOptions {
            return self.init(rawValue: 1 << 3)
        }
        
        /// 缓慢地
        public static var slowly: NoticeAlertOptions {
            return self.init(rawValue: 1 << 3)
        }
        
        /// 快速地
        public static var fast: NoticeAlertOptions {
            return self.init(rawValue: 1 << 4)
        }
        
        /// 颜色变浅
        public static var lighten: NoticeAlertOptions {
            return self.init(rawValue: 1 << 5)
        }
        
        /// 颜色变深
        public static var darken: NoticeAlertOptions {
            return self.init(rawValue: 1 << 6)
        }
        
        /// 消失
        public static var disappear: NoticeAlertOptions {
            return self.init(rawValue: 1 << 7)
        }
    }
    // MARK: - public property
    public var bodyMaxHeight = CGFloat(360) {
        didSet {
            updateContentFrame()
        }
    }
    
    /// 可通过手势移除通知
    public var allowRemoveByGesture = true
    
    /// 背景颜色
    public var themeColor = UIColor.ax_blue {
        didSet {
            contentView.backgroundColor = themeColor
            tintColor = themeColor.textColor()
        }
    }
    
    /// 模糊效果
    public var blurEffectStyle: UIBlurEffectStyle? {
        didSet {
            if let blur = blurEffectStyle {
                if self.visualEffectView == nil {
                    let vev = UIVisualEffectView.init(frame: self.bounds)
                    vev.effect = UIBlurEffect.init(style: blur)
                    if blur == UIBlurEffectStyle.dark {
                        tintColor = .white
                    } else {
                        tintColor = .black
                    }
                    vev.layer.masksToBounds = true
                    self.contentView.insertSubview(vev, at: 0)
                    if let pro = progressLayer {
                        vev.layer.addSublayer(pro)
                    }
                    self.visualEffectView = vev
                }
            }
        }
    }
    
    // MARK: subviews
    public var contentView = UIView()
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
            self.contentView.addSubview(loadTitleLabel())
            
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
            self.contentView.addSubview(loadTextView())
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
                    self.contentView.addSubview(v)
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
                var f = self.contentView.bounds
                f.size.width = progress * f.size.width
                self.progressLayer?.frame = f
            }
        }
    }
    
    public var level = NoticeBoard.Level.normal {
        didSet {
            windowLevel = level.rawValue
        }
    }
    
    public var tags = [String]()
    
    // MARK: - internal property
    // life cycle
    
    /// 持续的时间，0表示无穷大
    internal var duration = TimeInterval(0)
    
    /// 过期自动消失的函数
    internal var workItem : DispatchWorkItem?
    
    // action
    internal var block_action: ((Notice, UIButton)->Void)?
    
    internal weak var board = NoticeBoard.shared
    
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
            if let b = board {
                if b.layoutStyle == .tile {
                    if frame.size.height != lastFrame.size.height {
                        debugPrint("update frame")
                        lastFrame = frame
                        if let index = b.notices.index(of: self) {
                            b.updateLayout(from: index)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - public func
    
    /// 警示（如果一个notice已经post出来了，想要再次引起用户注意，可以使用次函数）
    ///
    /// - Parameter options: 操作
    public func alert(options: NoticeAlertOptions = []){
        let ani = CABasicAnimation.init(keyPath: "backgroundColor")
        ani.autoreverses = true
        ani.isRemovedOnCompletion = true
        ani.timingFunction = CAMediaTimingFunction.init(name: kCAMediaTimingFunctionEaseInEaseOut)
        if options.contains(.fast) {
            ani.duration = 0.38
        } else if options.contains(.slowly) {
            ani.duration = 2.4
        } else {
            // normally
            ani.duration = 0.8
        }
        if options.contains(.breathing) {
            ani.repeatCount = MAXFLOAT
        } else if options.contains(.twice) {
            ani.repeatCount = 2
        } else {
            // once
            ani.repeatCount = 1
        }
        if options.contains(.disappear) {
            ani.toValue = UIColor.init(white: 1, alpha: 0).cgColor
        } else if options.contains(.lighten) {
            ani.toValue = self.contentView.backgroundColor?.lighten(ratio: 0.4).cgColor
        } else {
            // darken
            ani.toValue = self.contentView.backgroundColor?.darken(ratio: 0.4).cgColor
        }
        self.contentView.layer.add(ani, forKey: "backgroundColor")
        
    }
    
    /// "→"按钮的事件
    ///
    /// - Parameter action: "→"按钮的事件
    open func actionButtonDidTapped(action: @escaping(Notice, UIButton) -> Void){
        self.contentView.addSubview(loadActionButton())
        updateContentFrame()
        block_action = action
    }
    open func removeFromNoticeBoard(){
        if let b = board {
            b.remove(self, animate: .slide)
        }
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

    
    public override init(frame: CGRect) {
        
        super.init(frame: frame)
        windowLevel = level.rawValue
        
        layer.shadowRadius = 12
        layer.shadowOffset = .init(width: 0, height: 8)
        layer.shadowOpacity = 0.35
        
        self.contentView = UIView.init(frame: self.bounds)
        self.contentView.layer.cornerRadius = cornerRadius
        self.contentView.clipsToBounds = true
        
        addSubview(self.contentView)
        
        loadActionButton()
        let pan = UIPanGestureRecognizer.init(target: self, action: #selector(self.pan(_:)))
        self.addGestureRecognizer(pan)
        
    }
    convenience init() {
        self.init(frame: .init(x: margin, y: margin, width: UIScreen.main.bounds.size.width - 2 * margin, height: titleHeight))
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
    
    // MARK: - action
    @objc private func touchDown(_ sender: UIButton) {
        debugPrint("touchDown: " + (sender.titleLabel?.text)!)
        if sender.tag == Tag.dragButton.rawValue {
            sender.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        } else if sender.tag == Tag.actionButton.rawValue {
            
        }
    }
    @objc private func touchUp(_ sender: UIButton) {
        debugPrint("touchUp: " + (sender.titleLabel?.text)!)
        if sender.tag == Tag.dragButton.rawValue {
            sender.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
        } else if sender.tag == Tag.actionButton.rawValue {
            
        }
    }
    @objc private func touchUpInside(_ sender: UIButton) {
        touchUp(sender)
        debugPrint("touchUpInside: " + (sender.titleLabel?.text)!)
        if sender == actionButton {
            if let action = block_action {
                action(self, sender)
            }
        }
        
    }
    @objc private func pan(_ sender: UIPanGestureRecognizer) {
        DispatchWorkItem.cancel(item: self.workItem)
        let point = sender.translation(in: sender.view)
        var f = self.frame
        f.origin.y += point.y
        self.frame = f
        sender.setTranslation(.zero, in: sender.view)
        if sender.state == .recognized {
            let v = sender.velocity(in: sender.view)
            if allowRemoveByGesture == true && (frame.origin.y + point.y < 0 || v.y < -1200) {
                if let b = self.board {
                    b.remove(self, animate: .slide)
                }
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
                        if let b = self.board {
                            b.post(self, duration: self.duration)
                        }
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


// MARK: - setup
private extension Notice {
    
    @discardableResult
    func loadTextView() -> UITextView {
        if let view = bodyView {
            return view
        } else {
            var y = CGFloat(0)
            if let titleLabel = self.titleLabel {
                y = titleLabel.frame.maxY
            }
            bodyView = UITextView.init(frame: .init(x: 0, y: y, width: self.frame.size.width, height: self.frame.size.height-y))
            bodyView?.tag = Tag.bodyView.rawValue
            bodyView?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            bodyView?.showsHorizontalScrollIndicator = false
            bodyView?.textAlignment = .justified
            bodyView?.isEditable = true
            bodyView?.isSelectable = false
            bodyView?.backgroundColor = .clear
            bodyView?.textContainerInset = defaultInset
            return bodyView!
        }
    }
    
    @discardableResult
    func loadIconView() -> UIImageView {
        if let view = iconView {
            return view
        } else {
            iconView = UIImageView.init(frame: .init(x: padding10, y: 2*padding4, width: titleHeight-4*padding4, height: titleHeight-4*padding4))
            iconView?.tag = Tag.iconView.rawValue
            iconView?.contentMode = .scaleAspectFit
            if debugMode {
                iconView?.backgroundColor = UIColor.init(white: 0, alpha: 0.3)
            }
            return iconView!
        }
    }
    
    
    @discardableResult
    func loadActionButton() -> UIButton {
        if let btn = actionButton {
            return btn
        } else {
            actionButton = UIButton.init(frame: .init(x: self.frame.size.width-38, y: 0, width: 38, height: titleHeight))
            actionButton?.tag = Tag.actionButton.rawValue
            actionButton?.setTitleColor(.black, for: .normal)
            actionButton?.setTitle("→", for: .normal)
            actionButton?.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            actionButton?.addTarget(self, action: #selector(self.touchUpInside(_:)), for: .touchUpInside)
            actionButton?.addTarget(self, action: #selector(self.touchDown(_:)), for: [.touchDown,])
            actionButton?.addTarget(self, action: #selector(self.touchUp(_:)), for: [.touchUpInside,.touchUpOutside])
            return actionButton!
        }
    }
    
    
    @discardableResult
    func loadTitleLabel() -> UILabel {
        if let lb = titleLabel {
            return lb
        } else {
            titleLabel = UILabel.init(frame: .init(x: padding10, y: 0, width: self.frame.size.width-2*padding10, height: titleHeight))
            titleLabel?.tag = Tag.titleView.rawValue
            titleLabel?.textAlignment = .justified
            titleLabel?.font = UIFont.boldSystemFont(ofSize: UIFont.labelFontSize-1)
            if debugMode {
                titleLabel?.backgroundColor = UIColor.init(white: 0, alpha: 0.2)
                actionButton?.backgroundColor = UIColor.init(white: 1, alpha: 0.2)
            }
            return titleLabel!
        }
    }
    
    @discardableResult
    func loadProgressLayer() -> CALayer {
        if let l = progressLayer {
            return l
        } else {
            progressLayer = CALayer.init()
            var f = self.contentView.bounds
            f.size.width = 0
            f.size.height = titleHeight + max(bodyMaxHeight, 0)
            progressLayer?.frame = f
            progressLayer?.backgroundColor = UIColor.init(white: 0, alpha: 0.2).cgColor
            if let blur = visualEffectView {
                blur.layer.insertSublayer(progressLayer!, above: blur.layer)
            } else {
                self.contentView.layer.insertSublayer(progressLayer!, at: 0)
            }
            return progressLayer!
        }
    }
    
    @discardableResult
    func loadDragButton() -> UIButton {
        if let btn = dragButton {
            return btn
        } else {
            dragButton = UIButton.init(frame: .init(x: 0, y: 0, width: self.frame.width, height: dragButtonHeight))
            dragButton?.tag = Tag.dragButton.rawValue
            dragButton?.backgroundColor = UIColor.init(white: 0, alpha: 0.1)
            dragButton?.setTitle("——", for: .normal)
            dragButton?.setTitleColor(tintColor, for: .normal)
            dragButton?.addTarget(self, action: #selector(self.touchDown(_:)), for: [.touchDown,])
            dragButton?.addTarget(self, action: #selector(self.touchUp(_:)), for: [.touchUpInside,.touchUpOutside])
            return dragButton!
        }
    }
    
    
}


