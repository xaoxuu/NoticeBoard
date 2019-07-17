//
//  NoticeBoard.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import Inspire

// MARK: - 定义
public extension NoticeBoard {
    
    /// 布局样式
    ///
    /// - tile:  平铺，默认（所有通知都可见，但是通知过多会超出屏幕）
    /// - stack: 堆叠（最新的通知会遮挡旧的通知）
    enum Layout {
        case tile,stack
    }
    
    /// 离开动画还是进入动画
    ///
    /// - buildIn: buildIn动画
    /// - buildOut: buildOut动画
    enum BuildInOut {
        case `in`, out
    }
    
    enum NoticeIndex {
        case first, last, all
    }
    
}


/// NoticeBoard: 用来管理多个Notice视图的管理器，不在视图层级中显示。
public class NoticeBoard {
    
    /// shared instance
    public static let shared = NoticeBoard()
    
    /// 当前显示的所有通知
    public var notices = [Notice]()
    
    /// 布局样式
    public var layout = Layout.tile
    
    @discardableResult
    public func post(_ notice: Notice) -> Notice {
        // FIXME: 弹出
        // 如果已经显示在页面上，就重新设置消失的时间
        if notices.contains(notice) {
            notice.startCountdown()
        } else {
            //            notice.updateContentFrame()
            // 准备显示
            notice.makeKeyAndVisible()
//            UIWindow.mainWindow.makeKeyAndVisible() 
            notice.layoutIfNeeded()
            notice.translate(.out)
            // 进入的动画
            DispatchQueue.main.async {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    notice.translate(.in)
                    if self.notices.contains(notice) == false {
                        self.notices.append(notice)
                    }
                    self.privUpdateLayout(from: 0)
                }) { (completed) in
                    notice.startCountdown()
                }
            }
        }
        return notice
    }
    
    /// 移除某个通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    public func remove(_ notice: Notice?) {
        if let bar = notice {
            if bar.isHidden == false {
                UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    bar.translate(.out)
                }) { (completed) in
                    bar.removeFromSuperview()
                }
            }
            if let index = notices.firstIndex(of: bar) {
                notices.remove(at: index)
                privUpdateLayout(from: index)
                NotificationCenter.default.post(name: Notice.didRemoved, object: notice)
            }
        }
    }
    
    public func remove(_ identifier: String) {
        for n in notices(identifier: identifier) {
            remove(n)
        }
    }
    
    public func remove(_ index: NoticeIndex) {
        switch index {
        case .first:
            if let n = notices.first {
                remove(n)
            }
        case .last:
            if let n = notices.last {
                remove(n)
            }
        case .all:
            for n in notices {
                remove(n)
            }
        }
    }
    
    
    /// 获取已经post出的notice实例
    /// - Parameter identifier: id标识
    public func notices(identifier: String) -> [Notice] {
        var ns = [Notice]()
        for n in notices {
            if n.identifier == identifier {
                ns.append(n)
            }
        }
        return ns
    }
    
    // init
    init() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.deviceOrientationDidChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // deinit
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}


// MARK: - 快速post和remove
public extension NoticeBoard {
    // MARK: POST
    @discardableResult
    class func post(_ notice: Notice) -> Notice {
        return shared.post(notice)
    }
    
    @discardableResult
    func post(_ scene: Notice.Scene = .default, title: String? = nil, message: String? = nil, icon: UIImage? = nil) -> Notice {
        return post(Notice(scene: scene, title: title, message: message, icon: icon))
    }
    
    @discardableResult
    class func post(_ scene: Notice.Scene = .default, title: String? = nil, message: String? = nil, icon: UIImage? = nil) -> Notice {
        return shared.post(scene, title: title, message: message, icon: icon)
    }
    
    
    // MARK: REMOVE
    /// 移除某个通知
    ///
    /// - Parameters:
    ///   - notice: 通知
    class func remove(_ notice: Notice?) {
        shared.remove(notice)
    }
    
    class func remove(_ identifier: String) {
        shared.remove(identifier)
    }
    
    class func remove(_ index: NoticeIndex) {
        shared.remove(index)
    }
    
}

// MARK: - post / remove / update layout
internal extension NoticeBoard {
    
    func privUpdateLayout(from: Int){
        for i in from ..< notices.count {
            let n = notices[i]
            var y = Notice.config.margin
            if i > 0 {
                if layout == .stack {
                    y += notices[i-1].frame.minY
                } else if layout == .tile {
                    y += notices[i-1].frame.maxY
                } else {
                    y += Inspire.shared.screen.safeAreaInsets.top
                }
            } else {
                y += Inspire.shared.screen.safeAreaInsets.top
            }
            
            UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.7, options: [.allowUserInteraction, .curveEaseOut], animations: {
                n.originY = y
            }) { (completed) in
                
            }
        }
    }
    
}

fileprivate extension NoticeBoard {
    
    @objc func deviceOrientationDidChange(_ notification: Notification){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: [.allowUserInteraction, .curveEaseOut], animations: {
                for notice in self.notices {
                    notice.setNeedsLayout()
                }
            }, completion: nil)
            self.privUpdateLayout(from: 0)
        }
    }
    
}
