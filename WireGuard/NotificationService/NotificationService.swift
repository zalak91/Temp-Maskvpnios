// SPDX-License-Identifier: MIT
// Copyright © 2018-2019 WireGuard LLC. All Rights Reserved.

import UserNotifications

class NotificationService: UNNotificationServiceExtension {

    let imageKey = AnyHashable("image")

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)

        if let imageUrl = request.content.userInfo[imageKey] as? String {
            print("imageurl under notification",imageUrl)
            //  imageUrl = "http://asta.b4live.com/images/cropped-131239288.jpg"
            let session = URLSession(configuration: URLSessionConfiguration.default)
            let task = session.dataTask(with: URL(string: imageUrl)!, completionHandler: { [weak self] (data, response, error) in
                if let data = data {
                    do {
                        let writePath = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("push.png")
                        try data.write(to: writePath)
                        guard let wself = self else {
                            return
                        }
                        if let bestAttemptContent = wself.bestAttemptContent {
                            let attachment = try UNNotificationAttachment(identifier: "nnsnodnb_demo", url: writePath, options: nil)
                            bestAttemptContent.attachments = [attachment]
                            contentHandler(bestAttemptContent)
                        }
                    } catch let error as NSError {
                        print(error.localizedDescription)

                        guard let wself = self else {
                            return
                        }
                        if let bestAttemptContent = wself.bestAttemptContent {
                            contentHandler(bestAttemptContent)
                        }
                    }
                } else if let error = error {
                    print(error.localizedDescription)
                }
            })
            task.resume()
        } else {
            if let bestAttemptContent = bestAttemptContent {
                contentHandler(bestAttemptContent)
            }
        }
    }

    override func serviceExtensionTimeWillExpire() {
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
