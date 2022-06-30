//
//  LogTableViewCell.swift
//  SocketLogger
//
//  Created by ntoworks on 2022/06/29.
//

import UIKit

class LogTableViewCell: UITableViewCell {

    @IBOutlet var logText: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
