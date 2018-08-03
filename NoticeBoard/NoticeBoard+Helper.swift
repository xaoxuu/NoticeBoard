//
//  NoticeBoard+Helper.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit

//internal var isIPhoneX: Bool = {
//    if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) || UIScreen.main.bounds.size.equalTo(CGSize.init(width: 812, height: 375)) {
//        return true
//    } else {
//        return false
//    }
//}()

internal var isIPhoneXPortrait: Bool = {
    if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) {
        return true
    } else {
        return false
    }
}()

internal extension UIWindow {
    internal static var mainWindow: UIWindow = {
        let responder = UIApplication.shared.delegate! as! UIResponder
        let window = responder.value(forKey: "window") as! UIWindow
        return window
    }()
}

internal extension DispatchWorkItem {
    internal static func cancel(_ item: DispatchWorkItem?) {
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
    static let ax_yellow = UIColor.init(red: 255/255, green: 235/255, blue: 59/255, alpha: 1)
    static let ax_red = UIColor.init(red: 244/255, green: 67/255, blue: 54/255, alpha: 1)
    static let ax_green = UIColor.init(red: 76/255, green: 175/255, blue: 80/255, alpha: 1)
    static let ax_blue = UIColor.init(red: 82/255, green: 161/255, blue: 248/255, alpha: 1)
    
    internal func darken(_ ratio: CGFloat = 0.5) -> UIColor {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = red * (1 - ratio)
        green = green * (1 - ratio)
        blue = blue * (1 - ratio)
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    internal func lighten(_ ratio: CGFloat = 0.5) -> UIColor {
        var red = CGFloat(0)
        var green = CGFloat(0)
        var blue = CGFloat(0)
        var alpha = CGFloat(0)
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        red = red * (1 - ratio) + ratio
        green = green * (1 - ratio) + ratio
        blue = blue * (1 - ratio) + ratio
        return UIColor.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    internal func textColor() -> UIColor {
        func isLightColor() -> Bool {
            if self == UIColor.clear {
                return true
            }
            var red = CGFloat(0)
            var green = CGFloat(0)
            var blue = CGFloat(0)
            var alpha = CGFloat(0)
            self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            let grayLevel = red * 0.299 + green * 0.587 + blue * 0.114
            if grayLevel >= 192.0/255.0 {
                return true
            } else {
                return false
            }
        }
        
        if isLightColor() {
            return .darkText
        } else {
            return .white
        }
    }
    
}

