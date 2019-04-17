//
//  WebService.swift
//  Caressa
//
//  Created by Hüseyin METİN on 22.03.2019.
//  Copyright © 2018 Hüseyin METİN. All rights reserved.
//

import UIKit

final public class WebAPI: NSObject {
    
    public static let shared: WebAPI = WebAPI()
    
    public var disableActivity: Bool = false
    
    public func post<T1: Encodable, T2: Decodable>(_ method: String, parameter: T1, completion: ((T2) -> Void)? = nil) {
        request(type: "POST", method, parameter: parameter, completion: completion)
    }
    
    public func get<T2: Decodable>(_ method: String, completion: ((T2) -> Void)? = nil) {
        let a: String? = nil
        request(type: "GET", method, parameter: a, completion: completion)
    }
    
    public func put(_ method: String, parameter: Data, completion: ((Bool) -> Void)? = nil) {
        request(type: "PUT", method, parameter: parameter, completion: completion)
    }
    
    public func delete(_ method: String, completion: ((Bool) -> Void)? = nil) {
        request(type: "DELETE", method, parameter: nil, completion: completion)
    }
    
    public func request(type: String, _ method: String, parameter: Data?, completion: ((Bool) -> Void)? = nil) {
        var urlOpt: URL? = URL(string: method)
        if !method.contains("http")  {
            urlOpt = URL(string: "\(APIConst.baseURL)\(method)")
        }
        guard let url = urlOpt else { return }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        urlRequest.httpMethod = type
        if let data = parameter {
            urlRequest.addValue("image/png", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = data
        } else {
            let token = SessionManager.shared.token ?? ""
            if !token.isEmpty {
                urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
            }
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if !self.disableActivity {
                ActivityManager.shared.startActivity()
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                ActivityManager.shared.stopActivity()
            }
            
            guard let _ = data, error == nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        }
        
        task.resume()
    }
    
    private func request<T1: Encodable, T2: Decodable>(type: String, _ method: String, parameter: T1?, completion: ((T2) -> Void)? = nil) {
        
        guard let url = URL(string: "\(APIConst.baseURL)\(method)") else { return }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60)
        urlRequest.httpMethod = type
        
        let token = SessionManager.shared.token ?? ""
        if !token.isEmpty {
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        if method == APIConst.generateSignedURL ||
            method == APIConst.message ||
            method.contains("uploaded_new_profile_picture")
        {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try! JSONManager().encoder.encode(parameter)
        } else
            if let parameter = parameter {
                urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let jsonData = try! JSONManager().encoder.encode(parameter)
                let dictParams = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: Any]
                let dictStr = (dictParams.compactMap({"\($0.key)=\($0.value)"}) as Array).joined(separator: "&")
                let data = dictStr.data(using: .ascii, allowLossyConversion: true)
                urlRequest.httpBody = data
        }
        
        #if DEBUG
        print(urlRequest.allHTTPHeaderFields ?? "")
        if let body = urlRequest.httpBody {
            print("")
            print("")
            print("\(method) request: \(String(data: body, encoding: .utf8) ?? "no httpBody")")
        }
        #endif
        
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            if !self.disableActivity {
                ActivityManager.shared.startActivity()
            }
        }
        
        let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            
            DispatchQueue.main.async {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                ActivityManager.shared.stopActivity()
            }
            
            guard let data = data, error == nil else { return }
            
            #if DEBUG
            print("")
            print("")
            print("\(method) response: \(String(data: data, encoding: .utf8) ?? "no data")")
            #endif
            
            do {
                if method == APIConst.generateSignedURL {
                    var res = String(data: data, encoding: .utf8)!
                    res = "{\"url\":" + res + "}"
                    print(res)
                    let newData = res.data(using: .utf8)!
                    let resModel = try JSONManager().decoder.decode(T2.self, from: newData)
                    completion?(resModel)
                    return
                }
                
                let responseModel = try JSONManager().decoder.decode(T2.self, from: data)
                
                completion?(responseModel)
            } catch {
                WindowManager.showMessage(type: .error, message: error.localizedDescription)
                print(String(data: data, encoding: .utf8) ?? "", error)
                return
            }
            
        }
        
        task.resume()
    }
    
}
