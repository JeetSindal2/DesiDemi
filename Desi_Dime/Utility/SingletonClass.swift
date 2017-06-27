//
//  SingletonClass.swift
//  Desi_Dime
//
//  Created by Jeet Mac Mimi on 26/06/17.
//  Copyright © 2017 Jeet. All rights reserved.
//

import UIKit

class SingletonClass: NSObject {

    class func sharedInstance() -> SingletonClass {
        var sharedInstance: SingletonClass? = nil
        var onceToken: Int = 0
        if (onceToken == 0) {
            /* TODO: move below code to a static variable initializer (dispatch_once is deprecated) */
            sharedInstance = SingletonClass()
        }
        onceToken = 1
        return sharedInstance!
    }
    
    /*
    func performOperation(withPost urlString: String, parameters params: [AnyHashable: Any], withSuccess responseReceived: @escaping (_: Any, _: Bool) -> Void) {
        var theRequest: NSMutableURLRequest? = generateURLRequest(withOperation: urlString, params: params)
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration)
        let dataTask: URLSessionDataTask? = session.dataTask(withRequest: theRequest, completionHandler: {(_ data: Data, _ response: URLResponse, _ error: Error?) -> Void in
            if data.length > 0 && error == nil {
                let parseString = String(data, encoding: String.Encoding.utf8)
                let data: Data? = parseString.data(using: String.Encoding.utf8)
                let jsonValue: [AnyHashable: Any]? = try? JSONSerialization.jsonObject(withData: data, options: [])
                DispatchQueue.main.async(execute: {() -> Void in
                    responseReceived(jsonValue, jsonValue?.count > 0)
                })
            }
            else {
                DispatchQueue.main.async(execute: {() -> Void in
                    responseReceived(error?.userInfo, false)
                })
            }
        })
        dataTask?.resume()
    }
 */

    
        func performOperation(withPost urlString: String, parameters params: [AnyHashable: Any], withSuccess responseReceived: @escaping (_: Any, _: Bool) -> Void) {
            
            //let dict = ["Email": "test@gmail.com", "Password":"123456"] as [String: Any]
            if let jsonData = try? JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) {
                
                
                let url = NSURL(string: urlString)!
                let request = NSMutableURLRequest(url: url as URL)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.addValue("application/json", forHTTPHeaderField: "Accept")
                request.addValue("\(jsonData.count)", forHTTPHeaderField:"Content-Length")
                
                request.httpBody = jsonData
                
                let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
                    if error != nil{
                        print(error?.localizedDescription)
                        return
                    }
                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? NSDictionary
                        
                        if let parseJSON = json {
                            let resultValue:String = parseJSON["success"] as! String;
                            print("result: \(resultValue)")
                            print(parseJSON)
                        }
                    } catch let error as NSError {
                        print(error)
                    }        
                }          
                task.resume()
            }
    }
    
    func performOperationWithGet(urlString: String, withSuccess responseReceived: @escaping (_: NSDictionary, _: Bool) -> Void) {
        
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(url: url as URL)
        request.httpMethod = "GET"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("text/javascript", forHTTPHeaderField: "Accept")
        request.addValue("7d7c5cacb355d043f07c7c9e4b38257ea5683f8d643b578683877a9b6a8bee1b", forHTTPHeaderField: "X-Desidime-Client")
        
        
        let task = URLSession.shared.dataTask(with: request as URLRequest){ data,response,error in
            if error != nil{
                print(error?.localizedDescription)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data!, options: []) as? NSDictionary
                
                if let parseJSON = json {
                    let resultValue:NSDictionary = parseJSON["deals"] as! NSDictionary;
                    print("result: \(resultValue)")
                    print(parseJSON)
                    
                    DispatchQueue.main.async{
                        responseReceived (resultValue, true)
                      }
                }
            } catch let error as NSError {
                print(error)
                
                DispatchQueue.main.async{
                    responseReceived ([:], false)
                }
            }
        }
        task.resume()

    }
    
}
