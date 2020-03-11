//
//  ArgAppUpdater.swift


import UIKit

enum VersionError: Error {
    case invalidBundleInfo, invalidResponse
}

class LookupResult: Decodable {
    var results: [AppInfo]
}

class AppInfo: Decodable {
    var version: String
    var trackViewUrl: String
    //let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
    // You can add many thing based on "http://itunes.apple.com/lookup?bundleId=\(identifier)"  response
    // here version and trackViewUrl are key of URL response
    // so you can add all key beased on your requirement.

}

class ArgAppUpdater: NSObject {
    private static var _instance: ArgAppUpdater?;

    private override init() {

    }

    public static func getSingleton() -> ArgAppUpdater {
        if (ArgAppUpdater._instance == nil) {
            ArgAppUpdater._instance = ArgAppUpdater.init();
        }
        return ArgAppUpdater._instance!;
    }

    private func getAppInfo(completion: @escaping (AppInfo?, Error?) -> Void) -> URLSessionDataTask? {
        guard let identifier = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String,
            let url = URL(string: "http://itunes.apple.com/lookup?bundleId=\(identifier)") else {
                DispatchQueue.main.async {
                    completion(nil, VersionError.invalidBundleInfo)
                }
                return nil
        }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            do {
                if let error = error { throw error }
                guard let data = data else { throw VersionError.invalidResponse }

                print("Data:::",data)
                print("response###",response!)

                let result = try JSONDecoder().decode(LookupResult.self, from: data)

                let dictionary = try? JSONSerialization.jsonObject(with: data, options: .mutableLeaves)

                print("dictionary",dictionary!)


                guard let info = result.results.first else { throw VersionError.invalidResponse }
                print("result:::",result)
                completion(info, nil)
            } catch {
                completion(nil, error)
            }
        }
        task.resume()

        print("task ******", task)
        return task
    }
    private  func checkVersion(force: Bool) {
        let info = Bundle.main.infoDictionary
        let currentVersion = info?["CFBundleShortVersionString"] as? String
        _ = getAppInfo { (info, error) in

            let appStoreAppVersion = info?.version

            if let error = error {
                print(error)



            }else if appStoreAppVersion!.compare(currentVersion!, options: .numeric) == .orderedDescending {
                //                print("needs update")
                // print("hiiii")
                DispatchQueue.main.async {
                    let topController: UIViewController = UIApplication.shared.keyWindow!.rootViewController!

                    topController.showAppUpdateAlert(version: (info?.version)!, force: force, appURL: (info?.trackViewUrl)!)
                }

            }
        }


    }

    func showUpdateWithConfirmation() {
        checkVersion(force : false)


    }

    func showUpdateWithForce() {
        checkVersion(force : true)
    }



}

extension UIViewController {


    fileprivate func showAppUpdateAlert( version : String, force: Bool, appURL: String) {
        print("AppURL:::::",appURL)

        let bundleName = "\(Bundle.main.infoDictionary!["CFBundleDisplayName"])"
        let alertMessage = "\(bundleName) Version \(version) is available on AppStore."
        let alertTitle = "New Version"


        let alertController = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)


        if !force {
            let notNowButton = UIAlertAction(title: "Not Now", style: .default) { (action:UIAlertAction) in
                print("Don't Call API");


            }
            alertController.addAction(notNowButton)
        }

        let updateButton = UIAlertAction(title: "Update", style: .default) { (action:UIAlertAction) in
            print("Call API");
            print("No update")
            guard let url = URL(string: appURL) else {
                return
            }
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }

        }

        alertController.addAction(updateButton)
        self.present(alertController, animated: true, completion: nil)
    }
}
