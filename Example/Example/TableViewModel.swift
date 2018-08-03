//
//  TableViewModel.swift
//  Example
//
//  Created by xaoxuu on 2018/7/4.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit

class TableViewModel: NSObject {
    
    
    enum ModelType {
        case title, body
    }
    
    var sections = [TableViewSectionModel]()
    
    init(_ type: ModelType) {
        
        let path = Bundle.main.path(forResource: "TableView", ofType: "plist")
        if let d = NSDictionary.init(contentsOfFile: path!) {
            switch type {
            case .title:
                
                let array = d.object(forKey: "title") as! [[String:Any]]
                for dict in array {
                    sections.append(TableViewSectionModel(dict: dict))
                }
                
            default:
                let array = d.object(forKey: "body") as! [[String:Any]]
                for dict in array {
                    sections.append(TableViewSectionModel(dict: dict))
                }
            }
        }
        
    }
    
}

class TableViewSectionModel: NSObject {
    var header = ""
    var rows = [String]()
    
    init(dict: [String:Any]) {
        header = dict["header"] as! String
        rows = dict["items"] as! [String]
    }
    
}
