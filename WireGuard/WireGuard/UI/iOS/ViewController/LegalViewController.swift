// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit

class LegalViewController: UIViewController {



    @IBOutlet weak var legaltableview: UITableView!



    var legalArr = [String]()
    override func viewDidLoad() {
        super.viewDidLoad()

        legaltableview.register(UINib(nibName: "LegalTableViewCell", bundle: nil), forCellReuseIdentifier: "legalCell")
        let backButton = UIBarButtonItem()
        backButton.title = "Settings"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationItem.title = "Legal"
        self.navigationController?.isNavigationBarHidden = false
        self.navigationController?.navigationBar.prefersLargeTitles = true
        self.navigationController?.navigationBar.isTranslucent = false


        legalArr = ["Privarcy Policy","Terms of Service","EULA"]

        // Do any additional setup after loading the view.
    }

}

extension LegalViewController : UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "legalCell", for: indexPath) as! LegalTableViewCell
        cell.topiclbl.text = legalArr[indexPath.row]
        return cell
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return legalArr.count
    }

}
