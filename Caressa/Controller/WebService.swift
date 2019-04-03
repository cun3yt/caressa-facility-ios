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
        guard let url = URL(string: method) else { return }
        
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.addValue("image/png", forHTTPHeaderField: "Content-Type")
        urlRequest.httpMethod = "PUT"
        urlRequest.httpBody = parameter
        
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
            
            guard let data = data, error == nil else {
                completion?(false)
                return
            }
            
            completion?(true)
        }
        
        task.resume()
    }
    
    private func request<T1: Encodable, T2: Decodable>(type: String, _ method: String, parameter: T1?, completion: ((T2) -> Void)? = nil) {
        var uri: URL?
        if type == "PUT" {
            uri = URL(string: method)
        } else {
            uri = URL(string: "\(APIConst.baseURL)\(method)")
        }
        guard let url = uri else { return }
        
        let token = method == APIConst.token ?
        "Basic QTZLYUZ5WE1XZEVBSTYzeXNUZWVhMlp0RFk0azV2V2VWY2w2eHFuczpucmhuUmlXcWNhRXNuTUJZbGFvTXp4dlJhNGxYTXFQZE9PbHlhUkM4VUpCV25sblZLZUtjWG1HWnBjVnA2Z2dMU2p4bDZtWk5wN2NlbW45ZEdtajJzemxKNFR0TVB0SjZoQmQwUTlCeHE0WWhuRGlRZWJ1Y0dkSlJ1Z2p6TmdPSw==" :
        SessionManager.shared.token ?? ""
        
        var urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10)
        urlRequest.httpMethod = type
        
        if !token.isEmpty {
            urlRequest.addValue(token, forHTTPHeaderField: "Authorization")
        }
        
        if method == APIConst.generateSignedURL {
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try! JSONManager().encoder.encode(parameter)
        } else
            if type == "PUT" {
              urlRequest.httpBody = parameter as! Data
        } else
            if let parameter = parameter {
                urlRequest.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
                let jsonData = try! JSONManager().encoder.encode(parameter)
                let dictParams = try! JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [String: Any]
                let dictStr = (dictParams.compactMap({"\($0.key)=\($0.value)"}) as Array).joined(separator: "&")
                let data = dictStr.data(using: .ascii, allowLossyConversion: true)
                urlRequest.httpBody = data
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
            
            guard let data = data, error == nil else { return }
            
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
                #if DEBUG
                print(urlRequest.allHTTPHeaderFields ?? "")
                if let body = urlRequest.httpBody {
                    print("")
                    print("")
                    print("\(method) request: \(String(data: body, encoding: .utf8) ?? "no httpBody")")
                }
                #endif
                
                #if DEBUG
                print("")
                print("")
                print("\(method) response: \(String(data: data, encoding: .utf8) ?? "no data")")
                #endif
                
                WindowManager.showMessage(type: .error, message: error.localizedDescription)
                print(String(data: data, encoding: .utf8) ?? "", error)
                return
            }
            
        }
        
        task.resume()
    }
    
}
