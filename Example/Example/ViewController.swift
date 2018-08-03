//
//  ViewController.swift
//  Example
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import WebKit
import NoticeBoard
class ViewController: UIViewController {

    let exampleVC = ExampleViewController()
    var web = WKWebView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNoti(_:)), name: NSNotification.Name(rawValue: DebuggerWindow.Tag.bg.cacheKey), object: nil)
        
        // load web bg
        web = WKWebView.init(frame: view.bounds)
        web.isHidden = true
        view.addSubview(web)
        if let url = URL.init(string: "https://cn.bing.com") {
            web.load(.init(url: url))
        }
        
        DispatchQueue.main.async {
            // load debugger
            let debugger = DebuggerWindow()
            debugger.makeKeyAndVisible()
            UIWindow.main()?.makeKeyAndVisible()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func receiveNoti(_ noti: Notification) {
        let bg = noti.object as! Int
        if bg == 0 {
            present(exampleVC, animated: false, completion: nil)
        } else {
            exampleVC.dismiss(animated: false, completion: nil)
        }
        if bg == 2 {
            web.isHidden = false
        } else {
            web.isHidden = true
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

