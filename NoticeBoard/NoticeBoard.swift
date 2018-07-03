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
    
    
    
    /// 默认布局的post通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    ///   - duration: 持续时间
    public class func post(_ notice: Notice, duration: TimeInterval){
        shared.post(notice, duration: duration)
    }
    /// 默认布局的post通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    ///   - duration: 持续时间
    public func post(_ notice: Notice, duration: TimeInterval){
        post(notice, duration: duration, layout: layoutStyle)
    }
    /// 自定义布局post通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    ///   - duration: 持续时间
    ///   - option: 操作
    public class func post(_ notice: Notice, duration: TimeInterval, layout: LayoutStyle) {
        shared.post(notice, duration: duration, layout: layout)
    }
    /// 自定义布局post通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    ///   - duration: 持续时间
    ///   - option: 操作
    public func post(_ notice: Notice, duration: TimeInterval, layout: LayoutStyle) {
        post(notice, duration: duration, layout: layout, animate: .slide)
    }
    
    /// 移除所有通知
    public class func clean() {
        shared.clean(animate: .slide, delay: 0)
    }
    /// 移除所有通知
    public func clean() {
        clean(animate: .slide, delay: 0)
    }
    /// 移除某个通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    public class func remove(_ notice: Notice?) {
        shared.remove(notice, animate: .slide, delay: 0)
    }
    /// 移除某个通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    public func remove(_ notice: Notice?) {
        remove(notice, animate: .slide, delay: 0)
    }
    
}


// MARK: - 快速post
public extension NoticeBoard {
    
    /// post一条消息，默认主题
    ///
    /// - Parameters:
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(message: String?, duration: TimeInterval) -> Notice {
        let notice = Notice.init(title: nil, icon: nil, body: message)
        notice.setTheme(.normal)
        post(notice, duration: duration)
        return notice
    }
    
    /// post一条消息
    ///
    /// - Parameters:
    ///   - theme: 主题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ theme: Notice.Theme, message: String?, duration: TimeInterval) -> Notice {
        let notice = Notice.init(title: nil, icon: nil, body: message)
        notice.setTheme(theme)
        post(notice, duration: duration)
        return notice
    }
    /// post一条消息
    ///
    /// - Parameters:
    ///   - color: 主题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ color: UIColor, message: String?, duration: TimeInterval) -> Notice {
        let notice = Notice.init(title: nil, icon: nil, body: message)
        notice.setTheme(color)
        post(notice, duration: duration)
        return notice
    }
    /// post一条消息
    ///
    /// - Parameters:
    ///   - blurEffect: 主题
    ///   - message: 消息内容
    ///   - duration: 持续时间
    @discardableResult
    public class func post(_ blurEffectTheme: UIBlurEffectStyle, message: String?, duration: TimeInterval) -> Notice {
        let notice = Notice.init(title: nil, icon: nil, body: message)
        notice.setTheme(blurEffectTheme)
        post(notice, duration: duration)
        return notice
    }
    
}

// MARK: - post / remove / update layout
extension NoticeBoard {
    
    internal func post(_ notice: Notice, duration: TimeInterval, layout: LayoutStyle, animate: AnimationStyle) {
        let t = notice.title
        let b = notice.body
        if t.count == 0 && b.count == 0 {
            return
        }
        
        layoutStyle = layout
        if layout == .remove {
            clean(animate: animate, delay: 0)
        }
        
        notice.translate(animate, .buildOut)
        notice.makeKeyAndVisible()
        
        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
            notice.translate(animate, .buildIn)
            if layout == .replace {
                self.clean(animate: .fade, delay: 0.5)
            }
            if self.notices.contains(notice) == false {
                self.notices.append(notice)
            }
            self.updateLayout(from: 0)
        }) { (completed) in
            if duration > 0 {
                weak var weak = notice
                DispatchWorkItem.postpone(duration, block: {
                    self.remove(weak, animate: animate)
                })
            }
        }
    }
    
    internal func clean(animate: AnimationStyle, delay: TimeInterval) {
        if let notice = notices.first {
            remove(notice, animate: animate, delay: delay)
            clean(animate: animate, delay: delay)
        }
    }
    internal func remove(_ notice: Notice?, animate: AnimationStyle) {
        remove(notice, animate: animate, delay: 0)
    }
    internal func remove(_ notice: Notice?, animate: AnimationStyle, delay: TimeInterval) {
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
