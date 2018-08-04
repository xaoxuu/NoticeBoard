//
//  NoticeBoard+Helper.swift
//  NoticeBoard
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit



internal let margin = CGFloat(8)
internal let padding10 = CGFloat(8)
internal let padding4 = CGFloat(4)

internal let cornerRadius = CGFloat(12)
internal let titleHeight = CGFloat(36)
internal let dragButtonHeight = CGFloat(24)

internal let maxWidth = CGFloat(500)
internal let defaultInset = UIEdgeInsets.init(top: padding10, left: padding4, bottom: padding10, right: padding4)

internal func topSafeMargin() -> CGFloat {
    if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) {
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
//
//internal var isIPhoneXPortrait: Bool = {
//    if UIScreen.main.bounds.size.equalTo(CGSize.init(width: 375, height: 812)) {
//        return true
//    } else {
//        return false
//    }
//}()

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
    
    convenience init(hex: String) {
        func filter(hex: String) -> NSString{
            let set = NSCharacterSet.whitespacesAndNewlines
            var str = hex.trimmingCharacters(in: set).lowercased()
            if str.hasPrefix("#") {
                str = String(str.suffix(str.count-1))
            } else if str.hasPrefix("0x") {
                str = String(str.suffix(str.count-2))
            }
            return NSString(string: str)
        }
        let hex = filter(hex: hex)
        let length = hex.length
        guard length == 3 || length == 4 || length == 6 || length == 8 else {
            print("无效的hex")
            self.init(hex: "000")
            return
        }
        func floatFrom(_ hex: String) -> CGFloat {
            var result = Float(0)
            Scanner(string: "0x"+hex).scanHexFloat(&result)
            var maxStr = "0xf"
            if length > 5 {
                maxStr = "0xff"
            }
            var max = Float(0)
            Scanner(string: maxStr).scanHexFloat(&max)
            result = result / max
            return CGFloat(result)
        }
        
        func substring(_ hex: NSString, loc: Int) -> String {
            if length == 3 || length == 4 {
                return hex.substring(with: NSRange.init(location: loc, length: 1))
            } else if length == 6 || length == 8 {
                return hex.substring(with: NSRange.init(location: 2*loc, length: 2))
            } else {
                return ""
            }
        }
        
        let r = floatFrom(substring(hex, loc: 0))
        let g = floatFrom(substring(hex, loc: 1))
        let b = floatFrom(substring(hex, loc: 2))
        var a = CGFloat(1)
        if length == 4 || length == 8 {
            a = floatFrom(substring(hex, loc: 3))
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    func hexString() -> String {
        func maxHexValue() -> CGFloat {
            var max = Float(0)
            Scanner(string: "0xff").scanHexFloat(&max)
            return CGFloat(max)
        }
        var r = CGFloat(0)
        var g = CGFloat(0)
        var b = CGFloat(0)
        var a = CGFloat(1)
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        let rr = String(format: "%02X", UInt32(r*maxHexValue()))
        let gg = String(format: "%02X", UInt32(g*maxHexValue()))
        let bb = String(format: "%02X", UInt32(b*maxHexValue()))
        let aa = String(format: "%02X", UInt32(a*maxHexValue()))
        
        print(rr,gg,bb,aa)
        return "#" + rr + gg + bb + aa
    }
}


internal extension NoticeBoard {
    /// 动画样式
    ///
    /// - slide: 滑动，默认
    /// - fade: 淡入淡出
    enum AnimationStyle {
        case slide, fade
    }
    /// 离开动画还是进入动画
    ///
    /// - buildIn: buildIn动画
    /// - buildOut: buildOut动画
    enum BuildInOut {
        case buildIn, buildOut
    }
}

internal extension Notice {
    enum Tag: Int {
        typealias RawValue = Int
        
        case iconView = 101
        case titleView = 102
        case actionButton = 103
        case bodyView = 201
        case dragButton = 301
        
    }
    
    func updateSelfFrame(){
        var totalHeight = CGFloat(0)
        if let rootView = self.rootViewController?.view {
            for view in rootView.subviews {
                if view.isEqual(self.rootViewController?.view) == false && view.isEqual(visualEffectView) == false {
                    totalHeight = max(totalHeight, view.frame.maxY)
                }
            }
            rootView.frame = CGRect.init(x: 0, y: 0, width: frame.size.width, height: totalHeight)
            self.visualEffectView?.frame = rootView.bounds
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
    }
    
    func frame(for tag: Tag) -> CGRect {
        if tag == .actionButton {
            return CGRect.init(x: self.frame.size.width-38, y: 0, width: 38, height: titleHeight)
        } else if tag == .bodyView {
            return CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height)
        } else if tag == .dragButton {
            return CGRect.init(x: 0, y: 0, width: self.frame.width, height: dragButtonHeight)
        } else {
            return .zero
        }
    }
    
    func updateContentFrame(){
        if let t1 = visible(titleLabel){
            var f = t1.frame
            if let t0 = visible(iconView) {
                if self.subviews.contains(t0) == false {
                    self.rootViewController?.view.addSubview(t0)
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
                self.rootViewController?.view.addSubview(loadDragButton())
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

// MARK: - setup
internal extension Notice {
    
    @discardableResult
    func loadTextView() -> UITextView {
        if let view = bodyView {
            return view
        } else {
            bodyView = UITextView.init(frame: frame(for: .bodyView))
            bodyView?.tag = Tag.bodyView.rawValue
            bodyView?.font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            bodyView?.showsHorizontalScrollIndicator = false
            bodyView?.textAlignment = .justified
            bodyView?.isEditable = false
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
            return iconView!
        }
    }
    
    
    @discardableResult
    func loadActionButton() -> UIButton {
        if let btn = actionButton {
            return btn
        } else {
            actionButton = UIButton.init(frame: frame(for: .actionButton))
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
            return titleLabel!
        }
    }
    
    @discardableResult
    func loadProgressLayer() -> CALayer {
        if let l = progressLayer {
            return l
        } else {
            progressLayer = CALayer.init()
            if var f = self.rootViewController?.view.bounds {
                f.size.width = 0
                f.size.height = titleHeight + max(bodyMaxHeight, 0)
                progressLayer?.frame = f
            }
            progressLayer?.backgroundColor = UIColor.init(white: 0, alpha: 0.2).cgColor
            if let blur = visualEffectView {
                blur.layer.insertSublayer(progressLayer!, above: blur.layer)
            } else {
                self.rootViewController?.view.layer.insertSublayer(progressLayer!, at: 0)
            }
            return progressLayer!
        }
    }
    
    @discardableResult
    func loadDragButton() -> UIButton {
        if let btn = dragButton {
            return btn
        } else {
            dragButton = UIButton.init(frame: frame(for: .dragButton))
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

