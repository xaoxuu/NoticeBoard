//
//  Notice.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/20.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import Inspire

// MARK: - 定义
public extension Notice {
    
    /// 当notice被移除时的通知
    static let didRemoved = NSNotification.Name.init("noticeDidRemoved")
    
    /// Notice的参数控制板（用于定制UI）
    struct Configuration {
        
        /// 最大宽度（用于优化横屏或者iPad显示）
        public var maxWidth = CGFloat(500)
        
        /// 标题字体
        public var titleFont = UIFont.boldSystemFont(ofSize: 20)
        
        /// 正文字体
        public var bodyFont = UIFont.systemFont(ofSize: 17)
        
        /// 圆角半径
        public var cornerRadius = CGFloat(12)
        
        public var margin = CGFloat(8)
        
        public var padding = CGFloat(8)
        
        public var iconSize = CGSize(width: 48, height: 48)
        
        /// 标题最多行数（0代表不限制）
        public var titleMaxLines = Int(0)
        /// 正文最多行数（0代表不限制）
        public var bodyMaxLines = Int(0)
        
        
        internal var loadSubviews: ((Notice, Scene, Model) -> Void)?
        
        internal var setupModel: ((Notice, Scene, Model) -> Void)?
        
        /// 自定义UI
        /// - Parameter callback: 回调代码
        public mutating func loadSubviews(_ callback: @escaping (Notice, Scene, Model) -> Void) {
            loadSubviews = callback
        }
        
        /// 自定义UI
        /// - Parameter callback: 回调代码
        public mutating func setupModel(_ callback: @escaping (Notice, Scene, Model) -> Void) {
            setupModel = callback
        }
        
        
    }
    
    /// 使用场景
    enum Scene {
        
        /// 默认场景（默认UI配置为毛玻璃白底黑字，持续2秒）
        case `default`
        
        /// 加载中场景（默认UI配置为毛玻璃白底黑字）
        case loading
        
        /// 成功场景（默认UI配置为绿底白字，持续2秒）
        case success
        
        /// 警告场景（默认UI配置为黄底黑字，持续2秒）
        case warning
        
        /// 错误场景（默认UI配置为红底白字，持续2秒）
        case error
        
        public var backgroundColor: UIColor {
            switch self {
            case .success:
                return UIColor("#7CC353")
            case .warning:
                return UIColor("#FFEB3B")
            case .error:
                return UIColor("#F44336")
            default:
                return .clear
            }
        }
        
        public var tintColor: UIColor {
            switch self {
            case .success, .error:
                return .white
            default:
                return UIColor("#333333")
            }
        }
        
    }
    
    /// 数据模型
    struct Model {
        
        /// 通知的标题
        var title: String?
        
        /// 通知的正文
        var message: String?
        
        /// 通知的图标
        var icon: UIImage?
        
        internal var tapCallback: (() -> Void)?
        internal var disappearCallback: (() -> Void)?
        
        init(title: String?, message: String?, icon: UIImage? = nil, action: (() -> Void)? = nil) {
            self.title = title
            self.message = message
            self.icon = icon
            self.tapCallback = action
        }
        
        /// 点击事件
        /// - Parameter callback: 回调
        mutating func didTapped(_ callback: (() -> Void)?) {
            tapCallback = callback
        }
        
    }
    
    /// 动画效果
    struct NoticeAlertOptions : OptionSet {
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
    
    /// UI配置
    public static var config = Configuration()
    
    /// id标识（相同的id代表同一个notice实体）
    var identifier = String(Date().timeIntervalSince1970)
    
    /// 图标
    public lazy var imageView: UIImageView = {
        let imgv = UIImageView()
        imgv.contentMode = .scaleAspectFit
        return imgv
    }()
    
    /// 标题
    public lazy var titleLabel: UILabel = {
        let lb = UILabel()
        lb.font = Notice.config.titleFont
        lb.textAlignment = .justified
        lb.numberOfLines = Notice.config.titleMaxLines
        return lb
    }()
    
    /// 正文
    public lazy var bodyLabel: UILabel = {
        let lb = UILabel()
        lb.font = Notice.config.bodyFont
        lb.textAlignment = .justified
        lb.numberOfLines = Notice.config.bodyMaxLines
        return lb
    }()
    
    /// 可通过手势移除通知
    public var enableGesture = true
    
    /// 数据模型
    lazy var model: Model = {
        return Model(title: "", message: "")
    }()
    
    /// 毛玻璃层
    var blurView: UIVisualEffectView? {
        didSet {
            oldValue?.removeFromSuperview()
            if let new = blurView {
                insertSubview(new, at: 0)
            }
        }
    }
    /// 持续的时间，0表示无穷大
    var duration = TimeInterval(0)
    
    /// 过期自动消失的函数
    var workItem : DispatchWorkItem?
    
    weak var board = NoticeBoard.shared
    
    /// 手指开始拖拽前的纵坐标
    var originY = Notice.config.margin {
        didSet {
            self.frame.origin.y = originY
        }
    }
    
    // MARK: - public func
    
    /// 警示（如果一个notice已经post出来了，想要再次引起用户注意，可以使用此函数）
    ///
    /// - Parameter options: 操作
    public func alert(options: NoticeAlertOptions = []){
        func animation(_ animation: CABasicAnimation) {
            animation.autoreverses = true
            animation.isRemovedOnCompletion = true
            animation.timingFunction = CAMediaTimingFunction.init(name: CAMediaTimingFunctionName.easeInEaseOut)
            
            if options.contains(.fast) {
                animation.duration = 0.38
            } else if options.contains(.slowly) {
                animation.duration = 2.4
            } else if options.contains(.normally) {
                animation.duration = 0.8
            } else {
                // 默认
                if options.contains(.breathing) {
                    animation.duration = 2.4
                } else {
                    animation.duration = 0.38
                }
            }
            
            if options.contains(.flash) {
                animation.toValue = UIColor.init(white: 1, alpha: 0).cgColor
            } else if options.contains(.lighten) {
                animation.toValue = self.rootViewController?.view.backgroundColor?.lighten(0.7).cgColor
            } else {
                // darken
                animation.toValue = self.rootViewController?.view.backgroundColor?.darken(0.3).cgColor
            }
            
            if options.contains(.breathing) {
                animation.repeatCount = MAXFLOAT
            } else if options.contains(.twice) {
                animation.repeatCount = 2
            } else {
                // once
                animation.repeatCount = 1
            }
            
        }
        let ani = CABasicAnimation.init(keyPath: "backgroundColor")
        animation(ani)
        view.layer.add(ani, forKey: "backgroundColor")
        
    }
    
    /// 移除通知
    public func remove(){
        board?.remove(self)
    }
   
    
    // MARK: - life cycle
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        // window
        windowLevel = UIWindow.Level(5000)
        backgroundColor = .clear
        layer.shadowRadius = 8
        layer.shadowOffset = .init(width: 0, height: 5)
        layer.shadowOpacity = 0.2
        
        // vc & view
        let vc = UIViewController()
        self.rootViewController = vc
        vc.view.frame = self.bounds
        vc.view.clipsToBounds = true
        vc.view.layer.masksToBounds = true
        vc.view.layer.cornerRadius = Notice.config.cornerRadius
        
        // 点击
        let tap = UITapGestureRecognizer(target: self, action: #selector(privDidTapped(_:)))
        addGestureRecognizer(tap)
        // 拖动
        let pan = UIPanGestureRecognizer(target: self, action: #selector(privDidPan(_:)))
        addGestureRecognizer(pan)
        
    }
    
    public convenience init(scene: Scene = .default, title: String? = nil, message: String? = nil, icon: UIImage? = nil, action: (() -> Void)? = nil) {
        // window
        let width = min(UIScreen.main.bounds.size.width - 2 * Notice.config.margin, Notice.config.maxWidth)
        let marginX = (UIScreen.main.bounds.size.width - width) / 2
        let preferredFrame = CGRect.init(x: marginX, y:  Notice.config.margin, width: width, height: 1)
        self.init(frame: preferredFrame)
        // model
        model = Model(title: title, message: message, icon: icon, action: action)
        // duration
        switch scene {
        case .loading:
            duration = 0
        default:
            duration = 2
        }
        // views
        if let callback = Notice.config.loadSubviews {
            callback(self, scene, model)
        } else {
            setupViews(scene: scene, model: model)
        }
        if let callback = Notice.config.setupModel {
            callback(self, scene, model)
            layoutIfNeeded()
        } else {
            updateFrame(with: model)
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        debugPrint("👌🏼 a notice(\(identifier)) did deinit")
        model.disappearCallback?()
    }
    
    /// 布局的默认实现
    /// - Parameter scene: 场景方案
    /// - Parameter model: 数据模型
    public func setupViews(scene: Scene, model: Model) {
        view.backgroundColor = scene.backgroundColor
        tintColor = scene.tintColor
        if [.default, .loading].contains(scene) {
            blurMask(.extraLight)
        } else {
            blurMask(nil)
        }
        view.addSubview(titleLabel)
        view.addSubview(bodyLabel)
        view.addSubview(imageView)
    }
    
    /// 更新布局的默认实现
    /// - Parameter model: 数据模型
    public func updateFrame(with model: Model) {
        // 设置数据
        titleLabel.text = model.title
        bodyLabel.text = model.message
        if let icon = model.icon {
            imageView.image = icon
        }
        // 开始布局
        let padding = Notice.config.padding
        let margin = Notice.config.margin
        let iconSize = Notice.config.iconSize
        // 图片布局
        var x = margin + padding, y = margin + padding
        imageView.frame = .init(x: x, y: y, width: iconSize.width, height: iconSize.height)
        // 标题
        x += iconSize.width + padding
        titleLabel.frame = .init(x: x, y: y, width: bounds.width - x - padding - margin, height: 20)
        titleLabel.sizeToFit()
        // 正文
        y += titleLabel.frame.height + margin
        bodyLabel.frame = .init(x: x, y: y, width: bounds.width - x - padding - margin, height: 20)
        bodyLabel.sizeToFit()
        
        // 更新notice的frame
        y += bodyLabel.frame.height + padding + margin
        frame.size.height = max(y, imageView.frame.maxY + padding + margin)
        blurView?.frame = bounds
        layoutIfNeeded()
    }
    
    
    // MARK: - private func
    
    /// 设置颜色
    open override var tintColor: UIColor!{
        didSet {
            imageView.tintColor = tintColor
            titleLabel.textColor = tintColor
            bodyLabel.textColor = tintColor
        }
    }
    
    /// 获取view
    var view: UIView {
        return rootViewController!.view
    }
    
    /// 开始倒计时
    internal func startCountdown() {
        workItem?.cancel()
        if duration > 0 {
            workItem = DispatchWorkItem.postpone(duration, block: { [weak self] in
                self?.remove()
            })
        }
    }
    
    /// 移动
    /// - Parameter buildInOut: 移入或者移出
    func translate(_ buildInOut: NoticeBoard.BuildInOut){
        switch buildInOut {
        case .in:
            transform = .identity
        case .out:
            if transform == .identity {
                let offset = frame.size.height + frame.origin.y + layer.shadowRadius + layer.shadowOffset.height
                transform = .init(translationX: 0, y: -offset)
            }
        }
    }
    
    
    /// 点击事件
    /// - Parameter sender: 手势
    @objc func privDidTapped(_ sender: UITapGestureRecognizer) {
        model.tapCallback?()
    }
    
    /// 滑动事件
    /// - Parameter sender: 手势
    @objc func privDidPan(_ sender: UIPanGestureRecognizer) {
        self.workItem?.cancel()
        let point = sender.translation(in: sender.view)
        var f = self.frame
        f.origin.y += point.y
        self.frame = f
        sender.setTranslation(.zero, in: sender.view)
        if sender.state == .recognized {
            let v = sender.velocity(in: sender.view)
            if enableGesture == true && ((frame.origin.y + point.y < 0 && v.y < 0) || v.y < -1200) {
                board?.remove(self)
            } else {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    self.frame.origin.y = self.originY
                }) { (completed) in
                    if self.duration > 0 {
                        self.startCountdown()
                    }
                }
            }
        }
    }
}

// MARK: - 快速设置

public extension Notice {
    
    @discardableResult
    func identifier(_ identifier: String) -> Notice {
        self.identifier = identifier
        return self
    }
    
    @discardableResult
    func duration(_ seconds: TimeInterval) -> Notice {
        duration = seconds
        startCountdown()
        return self
    }
    
    @discardableResult
    func didTapped(_ callback: (() -> Void)?) -> Notice {
        model.tapCallback = callback
        return self
    }
    
    @discardableResult
    func didDisappear(_ callback: (() -> Void)?) -> Notice {
        model.disappearCallback = callback
        return self
    }
    
    
    @discardableResult
    func update(title: String?) -> Notice {
        model.title = title
        titleLabel.text = title
        return self
    }
    
    @discardableResult
    func update(message: String?) -> Notice {
        model.message = message
        bodyLabel.text = message
        return self
    }
    
    @discardableResult
    func update(icon: UIImage?) -> Notice {
        model.icon = icon
        imageView.image = icon
        return self
    }
    
    @discardableResult
    func blurMask(_ blurEffectStyle: UIBlurEffect.Style?) -> Notice {
        if let s = blurEffectStyle {
            if let bv = blurView {
                bv.effect = UIBlurEffect.init(style: s)
            } else {
                blurView = UIVisualEffectView(effect: UIBlurEffect.init(style: s))
                blurView?.layer.masksToBounds = true
                blurView?.layer.cornerRadius = Notice.config.cornerRadius
            }
        } else {
            blurView?.removeFromSuperview()
            blurView = nil
        }
        return self
    }
}

// MARK: - 工具

internal extension DispatchWorkItem {
    @discardableResult
    static func postpone(_ delay: TimeInterval, block: @escaping @convention(block) () -> Swift.Void) -> DispatchWorkItem! {
        let item = DispatchWorkItem.init(block: block)
        let time = DispatchTime.now() + delay
        DispatchQueue.main.asyncAfter(deadline: time, execute: item)
        return item
    }
}
