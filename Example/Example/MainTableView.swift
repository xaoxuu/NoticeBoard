//
//  MainTableView.swift
//  Example
//
//  Created by xaoxuu on 2018/6/27.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import AXKit
import AXTableKit
import NoticeBoard

let kTitle = "title"
let kBody = "body"
let kIcon = "icon"
let kTheme = "theme"



let title: [String] = {
    return ["操作失败",
            "操作失败操作失败操作失败",
            "操作失败操作失败操作失败操作失败操作失败操作失败"]
}()

let icon: [String] = {
    return ["alert-circle"]
}()

let body: [String] = {
    return ["个反阿斯顿发斯蒂芬大师傅电..",
            "阿斯顿发斯蒂芬大师傅电, 方是个反阿斯顿发斯蒂芬大师傅电.",
            "阿斯顿发斯蒂阿斯顿发斯蒂芬大师傅电, 方是个反阿斯顿发斯蒂芬大师傅电饭锅地。是个反阿斯顿发斯蒂芬大师傅电饭锅地方是个反阿，斯顿发斯蒂芬大师傅电饭锅地方是个反阿斯顿发斯蒂芬大师傅电饭锅地方是个反芬大师傅是个反."]
}()

class MainTableView: AXTableView {

    
    override func ax_tableViewPreloadDataSource() -> AXTableModelProtocol {
        let model = AXTableModel.init()
        model.addSection { (section) in
            section?.headerTitle = "快速post"
            section?.addRow({ (row) in
                row?.title = "title0"
                row?.cmd = "0,-1,-1"
            })
            section?.addRow({ (row) in
                row?.title = "body0"
                row?.cmd = "-1,-1,0"
            })
            
            section?.addRow({ (row) in
                row?.title = "title0 + icon"
                row?.cmd = "0,0,-1"
            })
            section?.addRow({ (row) in
                row?.title = "title0 + body0"
                row?.cmd = "1,-1,0"
            })
            
            section?.addRow({ (row) in
                row?.title = "title0 + icon + body0"
                row?.cmd = "0,0,0"
            })
            
            
            
            
            
        }
        
        
        
        return model
    }
    
    override func ax_tableView(_ tableView: UITableView & AXTableViewProtocol, didSelectedRowAt indexPath: IndexPath, model: AXTableRowModelProtocol) {
        
        let n = Notice.init(title: nil, icon: nil, body: nil)
        
        let arr = model.cmd().components(separatedBy: ",").map { (str) -> Int in
            return Int(str)!
        }
        
        var a = -1
        a = arr[0]
        if a >= 0 {
            n.set(title: title[a])
        }
        
        a = arr[1]
        if a >= 0 {
            n.set(icon: UIImage.init(named: icon[a])!)
        }
        
        a = arr[2]
        if a >= 0 {
            n.set(body: body[a])
        }
        
        n.set(theme: .normal)
        
        NoticeBoard.post(n, duration: 2)
        
        
    }

}
