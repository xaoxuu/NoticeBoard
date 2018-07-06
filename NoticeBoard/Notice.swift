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

open class Notice: UIWindow {
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
        
        var stringValue : String {
            switch self {
            case .success:
                return "success"
            case .note:
                return "note"
            case .warning:
                return "warning"
            case .error:
                return "error"
            default:
                return "default"
            }
        }
        init () {
            self = .normal
        }
        
    }
    
    // MARK: - public property
    public var bodyMaxHeight = CGFloat(360) {
        didSet {
            updateContentFrame()
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
    let time: Date = {
        return Date()
    }()
    public var level = NoticeBoard.Level.normal {
        didSet {
            windowLevel = level.rawValue
        }
    }
    public var tags = [String]()
    
    // MARK: - internal property
    // action
    var block_action: ((Notice, UIButton)->Void)?
    
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
    
    /// 设置标题
    ///
    /// - Parameter title: 标题
    open func setTitle(_ title: String?){
        if let t = title {
            self.title = t
        } else {
            self.title = ""
        }
    }
    
    /// 设置正文
    ///
    /// - Parameter body: 正文
    open func setBody(_ body: String?){
        if let b = body {
            self.body = b
        } else {
            self.body = ""
        }
    }
    
    /// 设置主题
    ///
    /// - Parameters:
    ///   - backgroundColor: 背景色
    ///   - textColor: 文本色
    open func setTheme(backgroundColor: UIColor, textColor: UIColor){
        contentView.backgroundColor = backgroundColor
        tintColor = textColor
    }
    
    /// 设置主题
    ///
    /// - Parameter theme: 主题
    open func setTheme(_ theme: Theme) {
        setTheme(backgroundColor: theme.rawValue, textColor: theme.rawValue.textColor())
        tags.append(theme.stringValue)
    }
    
    /// 设置主题
    ///
    /// - Parameter backgroundColor: 背景色
    open func setTheme(_ color: UIColor) {
        setTheme(backgroundColor: color, textColor: color.textColor())
    }
    
    
    /// 设置主题
    ///
    /// - Parameter effect: 模糊效果
    open func setTheme(_ blurEffect: UIBlurEffectStyle){
        let vev = UIVisualEffectView.init(frame: self.bounds)
        vev.effect = UIBlurEffect.init(style: blurEffect)
        if blurEffect == UIBlurEffectStyle.dark {
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
    
    /// "→"按钮的事件
    ///
    /// - Parameter action: "→"按钮的事件
    open func actionButtonDidTapped(action: @escaping(Notice, UIButton) -> Void){
        self.contentView.addSubview(loadActionButton())
        updateContentFrame()
        block_action = action
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
        self.setTheme(theme)
    }
    public convenience init(theme: UIColor) {
        self.init()
        self.setTheme(theme)
    }
    public convenience init(theme: UIBlurEffectStyle) {
        self.init()
        self.setTheme(theme)
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
            if let action = block_action {
                action(self, sender)
            }
        }
        
    }
    @objc func pan(_ sender: UIPanGestureRecognizer) {
        
        let point = sender.translation(in: sender.view)
        var f = self.frame
        f.origin.y += point.y
        self.frame = f
        sender.setTranslation(.zero, in: sender.view)
        if sender.state == .recognized {
            let v = sender.velocity(in: sender.view)
            if frame.origin.y + point.y < 0 || v.y < -1200 {
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
internal extension Notice {
    
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


