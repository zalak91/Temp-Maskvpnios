// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class CountryTableViewCell: UITableViewCell {


    @IBOutlet weak var countryflagimg: CustomImageLoader!

    @IBOutlet weak var countrynamelbl: UILabel!

    @IBOutlet weak var selectedrowimg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
