// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Cocoa

class customcell: NSTableCellView {


    @IBOutlet weak var mainview: NSView!



    @IBOutlet weak var countryflagimgview: CustomImgLoader!

    @IBOutlet weak var countrynamelbl: NSTextField!

    @IBOutlet weak var tickimgview: NSImageView!

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }

}
