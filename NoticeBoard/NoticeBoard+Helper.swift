//
//  NoticeBoard+Helper.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit

public extension NoticeBoard {
    public static var systemStatusBar: UIView = {
        return UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as! UIView
    }()
    public static var customStatusBar: UIView = {
        let view : UIView
        view = UIView.init(frame: systemStatusBar.bounds)
        systemStatusBar.insertSubview(view, at: 0)
        return view
    }()
    internal static var isIPhoneX: Bool = {
        if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) || UIScreen.main.bounds.size.equalTo(CGSize.init(width: 812, height: 375)) {
            return true
        } else {
            return false
        }
    }()
    
    
    internal static var keyWindow: UIWindow = {
        let responder = UIApplication.shared.delegate! as! UIResponder
        let window = responder.value(forKey: "window") as! UIWindow
        return window
    }()
    internal static var rootView: UIView = {
        let responder = UIApplication.shared.delegate! as! UIResponder
        let window = responder.value(forKey: "window") as! UIWindow
        return (window.rootViewController?.view)!
    }()
    
    internal static func show(view: UIView, on: UIView) {
        if on.subviews.contains(view) == false {
            view.alpha = 0
            on.addSubview(view)
            UIView.animate(withDuration: 0.38) {
                view.alpha = 1
            }
        }
    }
    
    internal static func fitSize(textView: UITextView, height: CGFloat) {
        var frame = textView.frame
//        let height = textView.text.boundingRect(with: CGSize.init(width: textView.bounds.size.width, height: height), options: [.usesLineFragmentOrigin,.usesFontLeading], attributes: [NSAttributedStringKey.font:textView.font ?? .systemFont(ofSize: UIFont.systemFontSize)], context: nil).height
//        frame.size.height = textView.textContainerInset.top + textView.textContainerInset.bottom + height + 1
//        textView.frame = frame
        frame.size.height = min(textView.contentSize.height, height)
        textView.frame = frame
        
    }
    
}

internal extension DispatchWorkItem {
    internal static func cancel(item: DispatchWorkItem?) {
        if let it = item {
            it.cancel()
        }
    }
    @discardableResult
    internal static func postpone(_ delay: TimeInterval, block: @escaping @convention(block) () -> Swift.Void) -> DispatchWorkItem! {
        let item = DispatchWorkItem.init(block: block)
        let time = DispatchTime.now() + .milliseconds(Int(1000.0*delay))
        DispatchQueue.main.asyncAfter(deadline: time, execute: item)
        return item
    }
}

internal extension UIColor {
    internal func darken(ratio: CGFloat) -> UIColor {
        var red = 0.0 as CGFloat
        var green = 0.0 as CGFloat
        var blue = 0.0 as CGFloat
        var alpha = 0.0 as CGFloat
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = red * (1 - ratio)
        green = green * (1 - ratio)
        blue = blue * (1 - ratio)
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    internal func lighten(ratio: CGFloat) -> UIColor {
        var red = 0.0 as CGFloat
        var green = 0.0 as CGFloat
        var blue = 0.0 as CGFloat
        var alpha = 0.0 as CGFloat
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = red * (1 - ratio) + ratio
        green = green * (1 - ratio) + ratio
        blue = blue * (1 - ratio) + ratio
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    static let ax_yellow = UIColor.init(red: 255/255, green: 235/255, blue: 59/255, alpha: 1)
    static let ax_red = UIColor.init(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
    static let ax_green = UIColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
    static let ax_blue = UIColor.init(red: 82/255, green: 161/255, blue: 248/255, alpha: 1)
    
    
    
    internal func isLightColor() -> Bool {
        var red = 0.0 as CGFloat
        var green = 0.0 as CGFloat
        var blue = 0.0 as CGFloat
        var alpha = 0.0 as CGFloat
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let grayLevel = red * 0.299 + green * 0.587 + blue * 0.114
        if grayLevel >= 192.0/255.0 {
            return true
        } else {
            return false
        }
    }
    
    internal func textColor() -> UIColor {
        if self.isLightColor() {
            return .darkText
        } else {
            return .white
        }
    }
    
}

