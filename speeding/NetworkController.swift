//
//  NetworkController.swift
//  speeding
//
//  Created by hackintosh on 4/7/19.
//  Copyright © 2019 wilksmac. All rights reserved.
//

import Foundation

class NetworkController {
    
    static var rootString = "http://justwilks.com:4040/api"
    
    private static func buildRequest(endpoint: String, method: String, bodyData: [String:Any]?)->URLRequest{
        let url = URL(string: rootString + endpoint)!
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if let data = bodyData {
            let jsonData = try? JSONSerialization.data(withJSONObject: data)
            request.httpBody = jsonData
        }
        
        return request
    }
    
    static func postSpeed(dict: [String:Any], completion:@escaping(_ result: [String:Any]?)->Void){
        
        let request = buildRequest(endpoint: "/", method: "POST", bodyData: dict)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            
            guard let data = data, error == nil else {
                print(error?.localizedDescription ?? "No data")
                completion(nil)
                return
            }
            let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
            if let responseDict = responseJSON as? [String:Any] {
                completion(responseDict)
            } else {
                completion(nil)
            }
        }
        task.resume()
    }
    
}
