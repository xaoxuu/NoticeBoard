//
//  ViewController.swift
//  Example
//
//  Created by xaoxuu on 2018/6/15.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import NoticeBoard
import AXKit
import WebKit

let t1 = "操作失败"
let t2 = "阿斯顿发斯蒂"
let t3 = "阿斯顿发斯蒂芬大师傅傅电饭锅地电饭锅地方是个反"

let b1 = "个反阿斯顿发斯蒂芬大师傅电.."
let b2 =  "阿斯顿发斯蒂芬大师傅电, 方是个反阿斯顿发斯蒂芬大师傅电."
let b3 =  "s阿斯顿发斯蒂阿斯顿发斯蒂芬大师傅电, 方是个反阿斯顿发斯蒂芬大师傅电饭锅地。是个反阿斯顿发斯蒂芬大师傅电饭锅地方是个反阿，斯顿发斯蒂芬大师傅电饭锅地方是个反阿斯顿发斯蒂芬大师傅电饭锅地方是个反芬大师傅是个反."

class ViewController: UIViewController {

    lazy var debugger: DebuggerWindow = {
        return DebuggerWindow.init()
    }()
    var web = WKWebView.init()
    @IBOutlet weak var btn: UIButton!
    
    @IBAction func tapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        web.isHidden = !sender.isSelected
        UserDefaults.standard.set(sender.isSelected, forKey: "bg")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        btn.backgroundColor = UIColor.init(white: 1, alpha: 1)
        btn.layer.cornerRadius = 12
        btn.layer.shadowOpacity = 0.3
        btn.layer.shadowOffset = .init(width: 0, height: 2)
        btn.layer.shadowRadius = 8
        btn.setTitleColor(.darkText, for: .normal)
        btn.setTitle("background: white", for: .normal)
        btn.setTitle("background: web view", for: .selected)
        btn.isSelected = UserDefaults.standard.bool(forKey: "bg")
        btn.alpha = 0
        
        web = WKWebView.init(frame: view.bounds)
        web.isHidden = !btn.isSelected
        view.insertSubview(web, at: 0)
        if let url = URL.init(string: "https://cn.bing.com") {
            web.load(.init(url: url))
        }
        
        NoticeBoard.post(.error, message: "haha", duration: 2)
        NoticeBoard.post(.light, message: "haha", duration: 2)
    }
    override func viewDidAppear(_ animated: Bool) {
        let _ = debugger
        UIView.animate(withDuration: 0.38) {
            self.btn.alpha = 1
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

