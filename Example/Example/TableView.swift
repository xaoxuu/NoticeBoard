//
//  TableView.swift
//  Example
//
//  Created by xaoxuu on 2018/7/3.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import AXKit


protocol MyTableViewDelegate {
    func tableView(_ tableView: TableView, didSelectTitle: String)
}

class TableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    enum ModelType {
        case title, body
    }
    
    var type = ModelType.title {
        didSet {
            switch type {
            case .title:
                texts = ["操作成功",
                         "操作失败",
                         "这个标题比较长比较长",
                         "这个标题非常长非常长非常长非常长非常长",
                         "不要说我们没有警告过你",
                         "我们都有不顺利的时候",
                         "这真是让人尴尬",
                         "正在处理一些事情"]
            case .body:
                texts = ["请稍后重试",
                         "不要说我们没有警告过你",
                         "不要怪我们没有警告过你\n我们都有不顺利的时候\nSomething happened\n这真是让人尴尬\n请坐和放宽\n滚回以前的版本\n这就是你的人生\n是的，你的人生\n作者：Windows",
                         "正在处理一些事情"]
            }
            self.reloadData()
        }
    }
    
    var texts = [String]()
    var myDelegate: MyTableViewDelegate?
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        dataSource = self
        delegate = self
        
        self.separatorInset.left = 0
        self.rowHeight = estimatedRowHeight
        self.estimatedRowHeight = cellH
        
        self.register(UINib.init(nibName: "TableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return texts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        
        cell.lb.text = texts[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let d = myDelegate {
            d.tableView(self, didSelectTitle: texts[indexPath.row])
        }
    }

}
