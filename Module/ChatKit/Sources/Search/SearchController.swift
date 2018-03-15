//
//  SearchController.swift
//  ChatKit
//
//  Created by chenwei on 2017/10/3.
//

import UIKit

class SearchController: UISearchController {

    ///fix bug 必须添加这行 否则会崩溃
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    var showVoiceButton: Bool = false {
        didSet {
            if showVoiceButton {
                self.searchBar.showsBookmarkButton = true
             //   self.searchBar.setImage(CWAsset.SearchBar_voice.image, for: .bookmark, state: UIControlState())
             //   self.searchBar.setImage(CWAsset.SearchBar_voice_HL.image, for: .bookmark, state: .highlighted)
                
            } else {
                self.searchBar.showsBookmarkButton = false
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        
        self.searchBar.barTintColor = UIColor.searchBarTint
        self.searchBar.tintColor = UIColor.chatSystem
        self.searchBar.layer.borderWidth = 0.5
        self.searchBar.layer.borderColor = UIColor.searchBarBorder.cgColor
        self.searchBar.sizeToFit()
        
        //通过KVO修改特性
        let searchField = self.searchBar.value(forKey: "_searchField") as! UITextField
        searchField.layer.masksToBounds = true
        searchField.layer.borderWidth = 0.5
        searchField.layer.borderColor = UIColor.tableViewCellLine.cgColor
        searchField.layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
