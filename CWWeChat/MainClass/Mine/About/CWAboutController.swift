//
//  CWAboutController.swift
//  CWWeChat
//
//  Created by wei chen on 2017/4/12.
//  Copyright © 2017年 cwcoder. All rights reserved.
//

import UIKit
import YYText
import TableViewManager

class CWAboutController: CWBaseTableViewController {
    
    lazy var tableViewManager: TableViewManager = {
        return TableViewManager(tableView: self.tableView)
    }()
    
    //github链接
    var lienseLabel: YYLabel = {
        let lienseLabel = YYLabel()
        
        let textAttri = NSMutableAttributedString()
        
        let githubLink = "https://github.com/cwwise/CWWeChat"
        let content: NSString = "高仿微信 仅供学习\nhttps://github.com/cwwise/CWWeChat"
        
        textAttri.append(NSAttributedString(string: content as String))
        textAttri.yy_lineSpacing = 4.0
        textAttri.yy_alignment = .center
        
        let highlight = YYTextHighlight()
        highlight.setColor(UIColor.chatSystemColor())
        highlight.tapAction = ({containerView, text, range, rect in
            guard let url = URL(string: githubLink) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: { (_) in
                    log.debug("打开链接成功...")
                })
            } else {
                UIApplication.shared.openURL(url)
            }
        })
        let range = content.range(of: githubLink)
        textAttri.yy_setTextHighlight(highlight, range: range)
        
        lienseLabel.attributedText = textAttri
        lienseLabel.textColor = UIColor.gray
        lienseLabel.font = UIFont.systemFont(ofSize: 12)
        lienseLabel.numberOfLines = 2
        return lienseLabel
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "关于微信"
        
        setupItemData()
        setupUI()
    }
    
    func setupUI() {
        
        let headerViewHeight: CGFloat = 100
        let frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: headerViewHeight)
        let headerView = CWAboutHeaderView(frame: frame)
        headerView.iconPath = "Applogo"
        headerView.title = "微信 CWWeChat \(UIApplication.shared.appVersion)"
        self.tableView.tableHeaderView = headerView
        
        if let tableFooterView = self.tableView.tableFooterView {
            // footerViw
            tableFooterView.height = kScreenHeight - kNavigationBarHeight - headerViewHeight - 4*kDefaultItemCellHeight - 40
            tableFooterView.addSubview(self.lienseLabel)
            self.lienseLabel.snp.makeConstraints { (make) in
                make.left.right.equalTo(tableFooterView)
                make.bottom.equalTo(tableFooterView).offset(-1)
            }
        }
    
    }

    func setupItemData() {
        let item1 = Item(title: "去评分")
        let item2 = Item(title: "功能介绍")
        let item3 = Item(title: "系统通知")
        let item4 = Item(title: "投诉")
        tableViewManager.append(itemsOf: [item1, item2, item3, item4])
    }
}

