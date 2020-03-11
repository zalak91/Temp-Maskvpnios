// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UIKit
import Firebase
import GoogleSignIn
import FirebaseAuth


class SocialLoginViewController: UIViewController,GIDSignInDelegate{
  var tunnelsManager: TunnelsManager?

@IBOutlet weak var signInButton: GIDSignInButton!


    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().delegate = self

    }

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    @IBAction func loginbtn(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }


    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
              if let error = error {
          // ...
          return
        }

        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken,
                                                          accessToken: authentication.accessToken)
        // ...
          Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
              // ...
              return
            }

                // Perform any operations on signed in user here.
                let userId = user.userID                  // For client-side use only!
                let idToken = user.authentication.idToken // Safe to send to the server
                let fullName = user.profile.name
                let givenName = user.profile.givenName
                let familyName = user.profile.familyName
                let email = user.profile.email

            print("Email",email)

            let vc = UIStoryboard.init(name: "MainStoryboard", bundle: Bundle.main).instantiateViewController(withIdentifier: "firstVC") as? CheckfirstViewController
            vc?.setTunnelsManager(tunnelsManager: self.tunnelsManager!)
            self.navigationController?.pushViewController(vc!, animated: true)
            UserDefaults.standard.setSocialLoggedIn(value: true)
            UserDefaults.standard.synchronize()
            print("User successfully signin in app using google")
            // User is signed in
            // ...
          }
    }


    func setTunnelsManager(tunnelsManager: TunnelsManager) {

        print("Inside checkfirstvc setTunnelsManager")
        if(UserDefaults.standard.isLoggedIn() == false) {
            self.tunnelsManager = tunnelsManager

        } else {

            self.tunnelsManager = tunnelsManager

        }
    }
}
