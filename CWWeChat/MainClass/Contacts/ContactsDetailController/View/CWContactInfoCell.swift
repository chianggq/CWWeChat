//
//  CWContactInfoCell.swift
//  CWWeChat
//
//  Created by wei chen on 2017/4/13.
//  Copyright © 2017年 cwcoder. All rights reserved.
//

import UIKit
import ChatClient

// 修改命名 统一一些距离
private let spaceX: CGFloat  =  14.0
private let spaceY: CGFloat  =  12.0

class CWContactInfoCell: UITableViewCell {

    var userModel: Contact? {
        didSet {
            self.setupUserInfomation()
        }
    }
    
    //
    private lazy var avatarImageView: UIImageView = {
        let avatarImageView = UIImageView()
        avatarImageView.clipsToBounds = true
        avatarImageView.layer.cornerRadius = 5
        return avatarImageView
    }()
    
    private lazy var nikenameLabel: UILabel = {
        let nikenameLabel = UILabel()
        nikenameLabel.font = UIFont.systemFont(ofSize: 17)
        return nikenameLabel
    }()
    
    private lazy var usernameLabel: UILabel = {
        let usernameLabel = UILabel()
        usernameLabel.font = UIFont.systemFont(ofSize: 14)
        return usernameLabel
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.accessoryType = .none
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(nikenameLabel)
        self.contentView.addSubview(usernameLabel)
        
        p_addSnap()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func p_addSnap() {
        //头像
        avatarImageView.snp.makeConstraints { (make) in
            make.left.equalTo(spaceX)
            make.top.equalTo(spaceY)
            make.width.equalTo(self.avatarImageView.snp.height)
            make.centerY.equalTo(self.contentView)
        }
        
        //昵称
        nikenameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.avatarImageView.snp.right).offset(spaceX)
            make.bottom.equalTo(self.avatarImageView.snp.centerY).offset(-3.5)
        }
        
        //用户名
        usernameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self.nikenameLabel)
            make.top.equalTo(self.avatarImageView.snp.centerY).offset(5.0)
        }

    }
    
    func setupUserInfomation() {
        
        guard let userModel = userModel else {
            return
        }
        
        let nikename = userModel.nickname
        
        avatarImageView.kf.setImage(with: userModel.avatarUrl, placeholder: kDefaultHeadImage)
        
        nikenameLabel.text = nikename
        usernameLabel.text = "微信号："+userModel.username
    }
    
    

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
