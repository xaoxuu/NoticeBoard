//
//  TableView.swift
//  Example
//
//  Created by xaoxuu on 2018/7/3.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit
import NoticeBoard

protocol MyTableViewDelegate {
    func tableView(_ tableView: TableView, didSelectTitle: String)
}

class TableView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    var model = TableViewModel(.title)
    
    var myDelegate: MyTableViewDelegate?
    func loadData(_ type: TableViewModel.ModelType) {
        switch type {
        case .title:
            model = TableViewModel(.title)
        case .body:
            model = TableViewModel(.body)
        }
        self.reloadData()
        self.scrollToRow(at: .init(row: 0, section: 0), at: .top, animated: false)
    }
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        dataSource = self
        delegate = self
        
        tableFooterView = UIView.init(frame: .init(x: 0, y: 0, width: 1, height: 1))
        sectionFooterHeight = 8
        self.rowHeight = estimatedRowHeight
        self.estimatedRowHeight = cellH
        
        self.register(UINib.init(nibName: "TableViewCell", bundle: .main), forCellReuseIdentifier: "cell")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 24 + 8
        } else {
            return 24
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].rows.count
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].header
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        cell.lb.text = model.sections[indexPath.section].rows[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let d = myDelegate {
            d.tableView(self, didSelectTitle: model.sections[indexPath.section].rows[indexPath.row])
        }
    }

}
