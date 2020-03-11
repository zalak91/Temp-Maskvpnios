//
//  ApiManager.swift
//  Animation
//
//  Created by zalak.p on 18/11/19.
//  Copyright © 2019 zalak.p. All rights reserved.
//
//
//import UIKit
#if os(iOS)
  import UIKit
#endif

class ApiManager: NSObject {

    static let sharedInstance = ApiManager()



    func getAPICalls(apiURL: String, onSuccess: @escaping(Data) -> Void, onFailure: @escaping(Error) -> Void){

        let request: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: apiURL)! as URL)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if(error != nil){
                onFailure(error!)
            } else{

                onSuccess(data!)
            }
        })
        task.resume()
    }

    func postAPICalls(apiURL: String, params: Dictionary<String, Any> , onSuccess: @escaping(Data) -> Void, onFailure: @escaping(Error) -> Void){

        let request: NSMutableURLRequest = NSMutableURLRequest(url: NSURL(string: apiURL)! as URL)
        request.httpMethod = "POST"

        let headers = [
            "Content-Type": "application/json"
        ]
        request.allHTTPHeaderFields = headers
        guard let httpBody = try? JSONSerialization.data(withJSONObject: params, options: []) else {
            return
        }
        request.httpBody = httpBody

        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest, completionHandler: {data, response, error -> Void in
            if(error != nil){
                onFailure(error!)
            } else{

                onSuccess(data!)
            }
        })
        task.resume()
    }


    func networkcheckapicall(timeoutinterval : Int,completion: @escaping (Bool) -> Void) {

        let url = URL(string: "http://www.google.com/")!

        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = TimeInterval(timeoutinterval)
        configuration.timeoutIntervalForResource = TimeInterval(timeoutinterval)
        let session = URLSession(configuration: configuration)

        let task = session.dataTask(with: url) {(data, response, error) in
            //  guard let data = data else { return }
            print("api get called")
            DispatchQueue.main.async {

            }

            if let responseerror = error {
                print("Error in network check api call",responseerror)
                completion(false)
            }

            if let httpResponse = response as? HTTPURLResponse {
                print("statusCode: \(httpResponse.statusCode)")
                completion(true)
            }

        }

        task.resume()
    }



}
