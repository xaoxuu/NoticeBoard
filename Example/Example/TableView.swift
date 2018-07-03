//
//  TableView.swift
//  Example
//
//  Created by xaoxuu on 2018/7/3.
//  Copyright © 2018 Titan Studio. All rights reserved.
//

import UIKit


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
                texts = ["（清空）",
                         "操作成功",
                         "操作失败",
                         "不要说我们没有警告过你",
                         "我们都有不顺利的时候",
                         "这真是让人尴尬",
                         "正在处理一些事情",
                         "坐和放宽",
                         "请稍后重试",
                         "我们正在帮你搞定一切",
                         "这通常不会太久",
                         "不幸的是，它花费的时间比通常要长",
                         "滚回到以前的版本",
                         "你正在成功",
                         "这个标题非常长非常长非常长非常长非常长非常长",]
            case .body:
                texts = ["（清空）",
                         "请稍后重试",
                         "不要说我们没有警告过你",
                         "正在处理一些事情",
                         "不幸的是，它花费的时间比通常要长",
                         "不要怪我们没有警告过你\n我们都有不顺利的时候\nSomething happened\n这真是让人尴尬\n请坐和放宽\n滚回以前的版本\n这就是你的人生\n是的，你的人生\n作者：微软Windows团队",
                         "The more people you love, the weaker you are.\n你在乎的人越多，你就越脆弱。",
                         "The man who fears losing has already lost.\n怕输的人已经输了。",
                         "What do we have left once we abandon the lie?\n戳破谎言，我们还剩下什么？",
                         "Never forget what you are, for surely the world will not. Make it your strength. Then it can never be your weakness. Armor yourself in it, and it will never be used to hurt you.\n永远不要忘了你是谁，因为这个世界就不会。把你的特点变成你的力量，它就永远不会成为你的弱点。用它武装自己，它就永远不能伤害你。","世间本无公平可言，除非公平掌握在自己手中。",
                         "I choose my allies carefully and my enemies more carefully still .\n我小心选择同盟，但更谨慎选择敌人。",
                         "如果我回头，一切就都完了。",
                         "No man could protected him from himself.\n没人能保护自取灭亡的家伙。",
                         "Chaos is a ladder. Only the ladder is real and climb is all there is.\n混乱是一把阶梯。唯有这把阶梯是真实的，攀爬则是其中的全部。",
                         "大部分人在尝试后才知道自己真正想要什么。可悲的是，许多人在垂垂老矣之前并没有机会尝试。","The night is dark and full of terrirs.\n暗夜无边，危机四伏",
                         "真正的敌人，不会坐等风暴结束，他就是风暴",
                         "混乱不是深渊。\n混乱是阶梯。\n很多人想往上爬 却失败了\n且永无机会再试。\n他们坠落而亡。\n有人本有机会攀爬，\n但他们拒绝了。\n他们守着王国不放\n守着诸神\n守着爱情\n尽皆幻想。\n唯有阶梯是真实存在。\n攀爬才是生活的全部。"]
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
