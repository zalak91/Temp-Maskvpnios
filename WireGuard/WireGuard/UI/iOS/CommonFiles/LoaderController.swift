// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class LoaderController: NSObject {
    static let sharedInstance = LoaderController()
    private let activityIndicator = UIActivityIndicatorView()

    //MARK: - Private Methods -
    private func setupLoader() {
        removeLoader()

        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = .gray
        activityIndicator.color = .black
        //activityIndicator.backgroundColor = UIColor(hexString: "##E9EFF0").withAlphaComponent(0.10)
    }

    //MARK: - Public Methods -
    func showLoader(view : UIView) {


        let appDel = UIApplication.shared.delegate as! AppDelegate
        let holdingView = appDel.window!.rootViewController!.view!

        DispatchQueue.main.async {

            self.activityIndicator.center = holdingView.center
            self.activityIndicator.startAnimating()
            holdingView.addSubview(self.activityIndicator)

            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }

    func removeLoader(){
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.removeFromSuperview()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
}
