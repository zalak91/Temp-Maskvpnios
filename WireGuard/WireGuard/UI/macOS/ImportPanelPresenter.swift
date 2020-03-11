// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import Cocoa

class ImportPanelPresenter {
    var firstmacosviewcontroller: FirstMacOSViewController?
   /*
    static func presentImportPanel(tunnelsManager: TunnelsManager, sourceVC: NSViewController?) {
        guard let window = sourceVC?.view.window else { return }
        let openPanel = NSOpenPanel()
        openPanel.representedFilename = "phone"
        openPanel.prompt = tr("macSheetButtonImport")
        openPanel.allowedFileTypes = ["conf", "zip"]
        openPanel.allowsMultipleSelection = true
        openPanel.beginSheetModal(for: window) { [weak tunnelsManager] response in
            guard let tunnelsManager = tunnelsManager else { return }
            guard response == .OK else { return }
            TunnelImporter.importFromFile(urls: openPanel.urls, into: tunnelsManager, sourceVC: sourceVC, errorPresenterType: ErrorPresenter.self)
        }
    }
    */

    // below changed code for thekeyvpn

    static func presentImportPanel(tunnelsManager: TunnelsManager, sourceVC: NSViewController?) {
        guard let window = sourceVC?.view.window else { return }
        let openPanel = NSOpenPanel()
//        openPanel.representedFilename = "phone"
//        openPanel.prompt = tr("macSheetButtonImport")
//        openPanel.allowedFileTypes = ["conf", "zip"]
//        openPanel.allowsMultipleSelection = true
        openPanel.beginSheetModal(for: window) { [weak tunnelsManager] response in
            guard let tunnelsManager = tunnelsManager else { return }
            guard response == .OK else { return }
             let urlPath = Bundle.main.url(forResource: "phone", withExtension: "conf")
            TunnelImporter.importFromFile(urls: [urlPath!], into: tunnelsManager, sourceVC: sourceVC, errorPresenterType: ErrorPresenter.self) {
                // _ = FileManager.deleteFile(at: url)
            }
        }

    }
}
