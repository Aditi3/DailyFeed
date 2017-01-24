//
//  DailyFeedItemListCell.swift
//  DailyFeed
//
//  Created by TrianzDev on 20/01/17.
//  Copyright © 2017 trianz. All rights reserved.
//

import UIKit

class DailyFeedItemListCell: UICollectionViewCell {

    @IBOutlet weak var newsArticleImageView: TSImageView! {
        didSet {
            newsArticleImageView.layer.cornerRadius = 5.0
            newsArticleImageView.layer.borderColor = UIColor(white: 0.2, alpha: 0.1).cgColor
            newsArticleImageView.layer.borderWidth = 1.0
            newsArticleImageView.clipsToBounds = true
        }
    }
    
    @IBOutlet weak var newsArticleTitleLabel: UILabel!
    @IBOutlet weak var newsArticleAuthorLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
