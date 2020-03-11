// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class MenuTableViewCell: UITableViewCell {



    @IBOutlet weak var menuitemimgview: UIImageView!
    @IBOutlet weak var mainview: UIView!

    @IBOutlet weak var menuitemlbl: UILabel!

    @IBOutlet weak var lineview: UIView!

    @IBOutlet weak var dropdownimg: UIImageView!

    @IBOutlet weak var switchCustomView: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
