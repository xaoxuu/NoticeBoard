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

    lazy var debugger: DebuggerWindow = {
        return DebuggerWindow.init()
    }()
    var web = WKWebView.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        web = WKWebView.init(frame: view.bounds)
        web.isHidden = true
        view.addSubview(web)
        if let url = URL.init(string: "https://cn.bing.com") {
            web.load(.init(url: url))
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.receiveNoti(_:)), name: NSNotification.Name(rawValue: "web"), object: nil)
    }
    override func viewDidAppear(_ animated: Bool) {
        let _ = debugger
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @objc func receiveNoti(_ noti: Notification) {
        let hi = noti.object as! Bool
        print(hi)
        web.isHidden = hi
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

