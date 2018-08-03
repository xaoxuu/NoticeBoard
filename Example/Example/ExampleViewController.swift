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

class ExampleViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    

    var table = UITableView()
    
    let data = [["NoticeBoard.post(\"Hello World!\")",
                 "NoticeBoard.post(\"Hello World!\", duration: 2)"],
                ["NoticeBoard.post(.error, message: \"Something Happend\", duration: 5)",
                 "NoticeBoard.post(.dark, message: \"Good evening\", duration: 2)"],
                ["NoticeBoard.post(.light, title: \"Hello World\", message: \"I'm NoticeBoard.\", duration: 2)"],
                ["let img = UIImage.init(named: \"alert-circle\")\nNoticeBoard.post(.light, icon:img, title: \"Hello World\", message: \"I'm NoticeBoard.\", duration: 2)"],
                ["let img = UIImage.init(named: \"alert-circle\")\nNoticeBoard.post(.warning, icon: img, title: \"Warning\", message: \"Please see more info\", duration: 0) { (notice, sender) in\nNoticeBoard.post(\"button tapped\", duration: 1)\n}"],
                ["自定义view"]]
    
    
    let progressNotice = Notice.init(title: "正在加载...", icon: nil, body: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "NoticeBoard"
        
        table = UITableView.init(frame: view.bounds, style: .grouped)
        
//        view.addSubview(table)
        table.register(UINib.init(nibName: "TableViewCell", bundle: .main), forCellReuseIdentifier: "ExampleViewControllerCell")
        table.dataSource = self
        table.delegate = self
        
        table.tableFooterView = UIView.init(frame: .init(x: 0, y: 0, width: 1, height: 100))
        
        progressNotice.theme = .normal
        if let path = Bundle.main.path(forResource: "Examples.md", ofType: nil) {
            do {
                let md = try NSString.init(contentsOfFile: path, encoding: String.Encoding.utf8.rawValue) as String
                let mdView = MarkdownView()
                view.addSubview(mdView)
                mdView.frame = view.bounds
                mdView.load(markdown: md)
                // 外部链接
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
                            } else if cmd == "postpro" {
                                if idx == 1000 {
                                    func loop(_ i: Int){
                                        if i <= 100 {
                                            self!.progressNotice.progress = CGFloat(i)/100.0
                                            self!.progressNotice.title = "已完成：\(i)%"
                                            if i < 100 {
                                                DispatchQueue.main.asyncAfter(deadline: .now()+0.05, execute: {
                                                    loop(i+1)
                                                })
                                            } else {
                                                DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                                                    NoticeBoard.remove(self!.progressNotice)
                                                })
                                            }
                                        }
                                    }
                                    loop(0)
                                    NoticeBoard.post(self!.progressNotice)
                                } else if idx <= 100 {
                                    self?.progressNotice.progress = CGFloat(idx)/100.0
                                    NoticeBoard.post((self?.progressNotice)!)
                                }
                            } else if cmd == "postcustom" {
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
                        
                        
                        return false
                    } else {
                        return false
                    }
                }
            } catch {
                
            }
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ExampleViewControllerCell", for: indexPath) as! TableViewCell
        cell.lb.font = UIFont.init(name: "Menlo-Regular", size: 13)
        cell.lb.text = data[indexPath.section][indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "post一条消息，内容为\"Hello World!\""
        } else if section == 1 {
            return "post一条指定主题样式的消息"
        } else if section == 2 {
            return "post一条指定主题样式并且带标题的消息"
        } else if section == 3 {
            return "post一条指定主题样式并且带标题和icon的消息"
        } else if section == 4 {
            return "对于带有标题的消息，可以设置右边的按钮“→”"
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let section = indexPath.section
        let row = indexPath.row
        
        if section == 0 {
            if row == 0 {
                NoticeBoard.post("Hello World!")
            } else if row == 1 {
                NoticeBoard.post("Hello World!", duration: 2)
            }
        } else if section == 1 {
            if row == 0 {
                NoticeBoard.post(.error, message: "Something Happend", duration: 5)
            } else if row == 1 {
                NoticeBoard.post(.dark, message: "Good evening", duration: 2)
            }
        } else if section == 2 {
            if row == 0 {
                NoticeBoard.post(.light, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
            }
        } else if section == 3 {
            if row == 0 {
                let img = UIImage.init(named: "alert-circle")
                NoticeBoard.post(.light, icon:img, title: "Hello World", message: "I'm NoticeBoard.", duration: 2)
            }
        } else if section == 4 {
            if row == 0 {
                let img = UIImage.init(named: "alert-circle")
                NoticeBoard.post(.warning, icon: img, title: "Warning", message: "Please see more info", duration: 0) { (notice, sender) in
                    NoticeBoard.post("button tapped", duration: 1)
                }
            }
        } else if section == 5 {
            if row == 0 {
                
                let notice = Notice()
                let h = CGFloat(200)
                let w = notice.frame.width
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
                NoticeBoard.post(notice)
            }
        }
        
        
        
    }
    
}
