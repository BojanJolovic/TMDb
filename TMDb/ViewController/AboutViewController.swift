//
//  AboutViewController.swift
//  TMDb
//
//  Created by Bojan Jolovic on 28/07/2018.
//  Copyright © 2018 Bojan Jolovic. All rights reserved.
//

import UIKit
import Kingfisher

class AboutViewController: UIViewController {

    //MARK: - IBOutlet
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var titleLabel: UILabel!
    
    //MARK: - Let & Var
    var overview: String = ""
    var titleStr: String = ""
    var imageStr: String = ""
    
    //MARK: - Func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let imgUrl = URL(string: imageStr)

        imageView.kf.setImage(with: imgUrl)
        titleLabel.text = titleStr
        textView.text = overview
    }
}
