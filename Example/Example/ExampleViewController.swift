//
//  ExampleViewController.swift
//  Example
//
//  Created by xaoxuu on 2018/8/2.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import NoticeBoard
import AXKit
import MarkdownView
import SafariServices
import WebKit

class ExampleViewController: UIViewController {
    
    let progressNotice = Notice()
    
    var placeholder = UIImageView()
    
    var observer : Any?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "NoticeBoard"
        
        // 加载成功后保存截图，下次启动先显示截图，加载成功后移除截图。
        setupPlaceholder()
        
        progressNotice.theme = .normal
        if let path = Bundle.main.path(forResource: "Examples.md", ofType: nil) {
            do {
                let md = try NSString.init(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
                let mdView = MarkdownView()
                view.insertSubview(mdView, at: 0)
                mdView.frame = view.bounds
                mdView.alpha = 0
                mdView.isScrollEnabled = false
                mdView.load(markdown: md)
                mdView.onRendered = { [weak self] height in
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1, execute: {
                        // 加载成功后保存截图，下次启动先显示截图，加载成功后移除截图。
                        UIView.animate(withDuration: 0.38, animations: {
                            mdView.alpha = 1
                        }, completion: { (completed) in
                            self!.placeholder.removeFromSuperview()
                            self!.saveImage(UIImage.init(view: mdView))
                            mdView.isScrollEnabled = true
                        })
                    })
                }
                // 外链
                let externalURLs = ["https://github.com/xaoxuu/NoticeBoard/issues",
                                    "https://xaoxuu.com/docs/noticeboard"]
                
                mdView.onTouchLink = { [weak self] request in
                    guard let url = request.url else { return false }
                    
                    if url.scheme == "file" {
                        return false
                    } else if url.scheme == "https" {
                        if externalURLs.contains(url.absoluteString) {
                            UIApplication.shared.openURL(url)
                        } else {
                            let safari = SFSafariViewController(url: url)
                            self?.present(safari, animated: true, completion: nil)
                        }
                        return false
                    } else if url.scheme == "cmd" {
                        if let cmd = url.host, let idx = url.port {
                            if cmd == "fastpost" {
                                self!.postSimpleNotice(idx)
                            } else if cmd == "postpro" {
                                self!.postProgress(idx)
                            } else if cmd == "postcustom" {
                                self!.postCustomView(idx)
                            }
                        }
                        return false
                    } else {
                        return false
                    }
                }
            } catch {
                print(error)
            }
        }
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        if let o = observer {
            NotificationCenter.default.removeObserver(o)
        }
    }
    
    func setupPlaceholder() {
        // placeholder image
        func loadImage() -> UIImage?{
            let path = NSString.init(string: "screenshot.png").docPath() as String
            do {
                let data = try Data.init(contentsOf: URL.init(fileURLWithPath: path))
                return UIImage.init(data: data)
            } catch {
                return nil
            }
        }
        placeholder = UIImageView.init(frame: view.bounds)
        placeholder.image = loadImage()
        placeholder.contentMode = .scaleAspectFill
        placeholder.alpha = 0.3
        view.addSubview(placeholder)
        DispatchQueue.main.asyncAfter(deadline: .now()+5) {
            self.placeholder.removeFromSuperview()
        }
        
    }
    
    func saveImage(_ image: UIImage){
        if let data = UIImagePNGRepresentation(image) {
            let path = NSString.init(string: "screenshot.png").docPath() as String
            let url = URL.init(fileURLWithPath: path)
            do {
                try data.write(to: url, options: .atomic)
            } catch {
                print(error)
            }
        }
    }
    func postSimpleNotice(_ idx: Int){
        let img = UIImage.init(named: "alert-circle")
        switch idx {
        case 1:
            NoticeBoard.post("Hello World!")
        case 2:
            NoticeBoard.post("Hello World!", duration: 2)
        case 11:
            NoticeBoard.post(.error, message: "Something Happend", duration: 5)
        case 12:
            NoticeBoard.post(.dark, message: "Good evening", duration: 2)
        case 21:
            NoticeBoard.post(.light, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
        case 31:
            NoticeBoard.post(.light, icon:img, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
        case 41:
            NoticeBoard.post(.warning, icon: img, title: "Warning", message: "Please see more info", duration: 0) { (notice, sender) in
                NoticeBoard.post("button tapped", duration: 1)
            }
        default:
            print("xxx")
        }
    }
    
    func postProgress(_ idx: Int){
        if idx == 1000 {
            func loop(_ i: Int){
                if i <= 100 {
                    progressNotice.progress = CGFloat(i)/100.0
                    progressNotice.title = "已完成：\(i)%"
                    if i < 100 {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
                            loop(i+1)
                        })
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                            NoticeBoard.remove(self.progressNotice)
                        })
                    }
                }
            }
            loop(0)
            NoticeBoard.post(progressNotice)
        } else if idx <= 100 {
            progressNotice.progress = CGFloat(idx)/100.0
            NoticeBoard.post(progressNotice)
        }
    }
    
    
    func postCustomView(_ idx: Int){
        let notice = Notice()
        let w = notice.frame.width
        
        if idx == 1 {
            let h = w/8*3
            notice.blurEffectStyle = .light
            let view = UIView.init(frame: .init(x: 0, y: 0, width: w, height: h))
            // subviews
            let imgv = UIImageView.init(frame: .init(x: w/2 - 30, y: h/2 - 16 - 30, width: 60, height: 60))
            let img = UIImage.init(named: Bundle.appIconName())
            imgv.image = img
            imgv.contentMode = .scaleAspectFit
            imgv.layer.masksToBounds = true
            imgv.layer.cornerRadius = 15
            view.addSubview(imgv)
            
            let lb = UILabel.init(frame: .init(x: 0, y: imgv.frame.maxY + 8, width: w, height: 20))
            lb.textAlignment = .center
            lb.font = UIFont.systemFont(ofSize: 13)
            lb.text = "\(Bundle.init(for: NoticeBoard.self).bundleName()!) \(Bundle.init(for: NoticeBoard.self).bundleShortVersionString()!)"
            view.addSubview(lb)
            
            notice.contentView.addSubview(view)
            notice.actionButtonDidTapped(action: { (notice, sender) in
                notice.removeFromNoticeBoard()
            })
            notice.actionButton?.setTitle("✕", for: .normal)
        } else if idx == 2 {
            let h = w/8*5
            let view = UIView.init(frame: .init(x: 0, y: 0, width: w, height: h))
            let imgv = UIImageView.init(frame: view.bounds)
            let img = UIImage.init(named: "firewatch")
            imgv.image = img
            imgv.contentMode = .scaleAspectFill
            imgv.layer.masksToBounds = true
            imgv.layer.cornerRadius = 15
            view.addSubview(imgv)
            notice.contentView.addSubview(view)
        } else if idx == 3 {
            let h = w*1.5
            let web = WKWebView.init(frame: .init(x: 0, y: -4, width: w, height: h))
            if let url = URL.init(string: "https://xaoxuu.com") {
                web.load(URLRequest.init(url: url))
                notice.contentView.addSubview(web)
                notice.actionButtonDidTapped(action: { (notice, sender) in
                    notice.removeFromNoticeBoard()
                })
                notice.actionButton?.setTitle("✕", for: .normal)
            }
            
        }
        
        NoticeBoard.post(notice)
        
    }
}
