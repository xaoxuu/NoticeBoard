//
//  NoticeBoard.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit

internal let debugMode = false


open class NoticeBoard: NSObject {
    
    /// 布局样式
    ///
    /// - tile:  平铺，默认（所有通知都可见，但是通知过多会超出屏幕）
    /// - replace: 取代旧的通知（旧的采用fade动画淡出）
    /// - remove: 移除旧的通知（旧的采用moveout动画移出屏幕）
    /// - overlay: 覆盖在旧的通知上层（切勿堆积过多）
    /// - stack: 堆叠（最新的通知会遮挡旧的通知）
    public enum LayoutStyle {
        case tile,replace,remove,overlay,stack
    }
    
    /// 动画样式
    ///
    /// - slide: 滑动，默认
    /// - fade: 淡入淡出
    internal enum AnimationStyle {
        case slide, fade
    }
    
    /// 离开动画还是进入动画
    ///
    /// - buildIn: buildIn动画
    /// - buildOut: buildOut动画
    internal enum BuildInOut {
        case buildIn, buildOut
    }
    
    public enum Level: UIWindowLevel {
        case low = 4000
        case normal = 4100
        case high = 4200
        case veryHigh = 4300
        
        var stringValue : String {
            switch self {
            case .low:
                return "low"
            case .normal:
                return "normal"
            case .high:
                return "high"
            case .veryHigh:
                return "veryHigh"
            }
        }
    }
    
    public static let shared = NoticeBoard()
    
    /// 当前显示的所有通知
    public var notices = [Notice]()
    /// 布局样式
    public var layoutStyle = LayoutStyle.tile
    
    
    
    /// post一条通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    ///   - duration: 持续时间
    @objc public class func post(_ notice: Notice, duration: TimeInterval = 0){
        shared.post(notice, duration: duration)
    }
    
    /// post一条通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    ///   - duration: 持续时间
    @objc public func post(_ notice: Notice, duration: TimeInterval = 0){
        post(notice, duration: duration, animate:.slide)
    }
    
    /// 移除所有通知
    @objc public class func clean() {
        shared.clean(animate: .slide, delay: 0)
    }
    /// 移除所有通知
    @objc public func clean() {
        clean(animate: .slide, delay: 0)
    }
    /// 移除某个通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    @objc public class func remove(_ notice: Notice?) {
        shared.remove(notice, animate: .slide, delay: 0)
    }
    /// 移除某个通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    @objc public func remove(_ notice: Notice?) {
        remove(notice, animate: .slide, delay: 0)
    }
    
    override init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(_:)), name: .UIDeviceOrientationDidChange, object: nil)
    }
    
    @objc func deviceOrientationDidChange(_ notification: Notification){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .curveEaseOut], animations: {
                for notice in self.notices {
                    notice.setNeedsLayout()
                }
            }, completion: nil)
            self.updateLayout(from: 0)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - 快速post
public extension NoticeBoard {
    
    /// post一条纯文本消息，默认主题
    ///
    /// - Parameters:
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ message: String?, duration: TimeInterval = 0) -> Notice {
        return post(.light, icon: nil, title: nil, message: message, duration: duration)
    }
    
    /// post一条消息（纯色主题+消息内容）
    ///
    /// - Parameters:
    ///   - theme: 主题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ theme: Notice.Theme, message: String?, duration: TimeInterval) -> Notice {
        return post(theme, icon: nil, title: nil, message: message, duration: duration)
    }
    /// post一条消息（UIBlurEffect主题+消息内容）
    ///
    /// - Parameters:
    ///   - blurEffectStyle: 主题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ theme: UIBlurEffectStyle, message: String?, duration: TimeInterval) -> Notice {
        return post(theme, icon: nil, title: nil, message: message, duration: duration)
    }
    
    
    /// post一条消息（纯色主题+消息标题+消息内容）
    ///
    /// - Parameters:
    ///   - theme: 主题
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ theme: Notice.Theme, title: String?, message: String?, duration: TimeInterval) -> Notice {
        return post(theme, icon: nil, title: title, message: message, duration: duration)
    }
    /// post一条消息（UIBlurEffect主题+消息标题+消息内容）
    ///
    /// - Parameters:
    ///   - blurEffectStyle: 主题
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ theme: UIBlurEffectStyle, title: String?, message: String?, duration: TimeInterval) -> Notice {
        return post(theme, icon: nil, title: title, message: message, duration: duration)
    }
    
    
    /// post一条消息（纯色主题+icon+消息标题+消息内容+按钮）
    ///
    /// - Parameters:
    ///   - theme: 主题
    ///   - icon: 图标
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    ///   - action: 按钮事件
    @discardableResult
    public class func post(_ theme: Notice.Theme, icon: UIImage?, title: String?, message: String?, duration: TimeInterval, action: ((Notice, UIButton) -> Void)? = nil) -> Notice {
        let notice = Notice.init(title: title, icon: icon, body: message)
        notice.theme = theme
        if let ac = action {
            notice.actionButtonDidTapped(action: ac)
        }
        shared.post(notice, duration: duration)
        return notice
    }
    
    /// post一条消息（UIBlurEffectStyle主题+icon+消息标题+消息内容+按钮）
    ///
    /// - Parameters:
    ///   - blurEffectStyle: 主题
    ///   - icon: 图标
    ///   - title: 标题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    ///   - action: 按钮事件
    @discardableResult
    public class func post(_ theme: UIBlurEffectStyle, icon: UIImage?, title: String?, message: String?, duration: TimeInterval, action: ((Notice, UIButton) -> Void)? = nil) -> Notice {
        let notice = Notice.init(title: title, icon: icon, body: message)
        notice.blurEffectStyle = theme
        if let ac = action {
            notice.actionButtonDidTapped(action: ac)
        }
        shared.post(notice, duration: duration)
        return notice
    }
    
    
}

// MARK: - post / remove / update layout
extension NoticeBoard {
    
    internal func post(_ notice: Notice, duration: TimeInterval, animate: AnimationStyle) {
        // 如果已经显示在页面上，就重新设置消失的时间
        if notices.contains(notice) {
            DispatchWorkItem.cancel(notice.workItem)
            if duration > 0 {
                weak var n = notice
                notice.workItem = DispatchWorkItem.postpone(duration, block: {
                    self.remove(n, animate: animate)
                })
            }
        } else {
            if layoutStyle == .remove {
                clean(animate: animate, delay: 0)
            }
            notice.updateContentFrame()
            notice.translate(animate, .buildOut)
            notice.duration = duration
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    notice.makeKeyAndVisible()
                    UIWindow.mainWindow.makeKeyAndVisible()
                    notice.translate(animate, .buildIn)
                    if self.layoutStyle == .replace {
                        self.clean(animate: .fade, delay: 0.5)
                    }
                    if self.notices.contains(notice) == false {
                        self.notices.append(notice)
                    }
                    self.updateLayout(from: 0)
                }) { (completed) in
                    DispatchWorkItem.cancel(notice.workItem)
                    if duration > 0 {
                        weak var n = notice
                        notice.workItem = DispatchWorkItem.postpone(duration, block: {
                            self.remove(n, animate: animate)
                        })
                    }
                }
            }
        }
    }
    
    internal func clean(animate: AnimationStyle, delay: TimeInterval) {
        if let notice = notices.first {
            remove(notice, animate: animate, delay: delay)
            clean(animate: animate, delay: delay)
        }
    }
    
    internal func remove(_ notice: Notice?, animate: AnimationStyle, delay: TimeInterval = 0) {
        if let bar = notice {
            if bar.isHidden == false {
                UIView.animate(withDuration: 1, delay: delay, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    bar.translate(animate, .buildOut)
                }) { (completed) in
                    bar.removeFromSuperview()
                }
            }
            if let index = notices.index(of: bar) {
                notices.remove(at: index)
                updateLayout(from: index)
                NotificationCenter.default.post(name: Notice.didRemoved, object: notice)
            }
        }
    }
    
    internal func updateLayout(from: Int){
        for i in from ..< notices.count {
            var y = margin
            if i > 0 {
                if layoutStyle == .stack {
                    y += notices[i-1].frame.minY
                } else if layoutStyle == .tile {
                    y += notices[i-1].frame.maxY
                } else {
                    y = topSafeMargin()
                }
            } else {
                y = topSafeMargin()
            }
            let n = notices[i]
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                n.originY = y
            }) { (completed) in
                
            }
        }
    }
    
}
