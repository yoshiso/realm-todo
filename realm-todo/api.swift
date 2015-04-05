//
//  api.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/31.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import Alamofire
import SwiftyJSON
import SwiftTask
import URITemplate

typealias ApiRequest = Task<Int,JSON,NSError>


class Api {
    
    // workaround tips 
    // After updated swift 1.2, use ( static var someVariable: Int = 0 ) instead
    private struct OAuthTokenStruct{ static var token: String? }
    class var OAuthToken: String? {
        get{ return OAuthTokenStruct.token }
        set{ OAuthTokenStruct.token = newValue }
    }
    private struct BaseUrlStringStruct{ static var url = "http://demo0664227.mockable.io" }
    class var BaseUrlString: String {
        get{ return BaseUrlStringStruct.url }
        set{ BaseUrlStringStruct.url = newValue }
    }
    
    class func defaultURLRequest(let path: String, let method: Alamofire.Method) -> NSMutableURLRequest {
        let URL = NSURL(string: Api.BaseUrlString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = Api.OAuthToken {
            mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        return mutableURLRequest
    }
    
    class func generateURI(template: String, params: [String: AnyObject]?) -> String {
        if let params = params {
            return URITemplate(template: template).expand(params)
        }
        return template
    }
    
    class Base {
        
        class func request(URLRequest: URLRequestConvertible) -> ApiRequest {
            return ApiRequest {(progress, fulfill, reject, configure) in
                let alam = Alamofire.request(URLRequest)
                                    .validate()
                                    .responseJSON({ (req, res, data, err) -> Void in
                    if let err = err {
                        println("ERROR: \(err)")
                        reject(self.buildErr(res, data: data, err: err))
                        return
                    }
                    let json = JSON(data!)
                    println("Response: ")
                    println(json)
                    fulfill(json)
                })
                debugPrintln(alam)
                configure.pause  = { alam.suspend() }
                configure.resume = { alam.resume()  }
                configure.cancel = { alam.cancel()  }
            }
        }
        
        class func buildErr(res: NSHTTPURLResponse?, data: AnyObject?, err: NSError?) -> NSError {
            var userInfo = [String: AnyObject]()
            if let res = res {
                userInfo["statusCode"] = res.statusCode
            }else{
                userInfo["statusCode"] = 502
            }
            if let data: AnyObject = data {
                userInfo["response"] = data
            }
            var error = NSError(domain: "com.aries.error", code: -1, userInfo: userInfo)
            debugPrintln("ERROR:")
            debugPrintln(error)
            return error
        }
        
    }
    
    class TodoItem: Base {
        
        // case nil object
        class func Read() -> ApiRequest {
            var params: [String: AnyObject]? = nil
            return request(Router.Read(params))
        }
        
        // case with all template param
        class func Create(username: String, password: String? = nil) -> ApiRequest {
            var params = [String: AnyObject]()
            
            params["username"] = username
            if let password = password {
                params["password"] = password
            }
            
            return request(Router.Create(params))
        }
        
        // case with chipped template param
        class func Update(id: String, password: String) -> ApiRequest {
            var params = [String: AnyObject]()
            
            params["id"] = id
            
            return request(Router.Update(params))
        }
        
        private enum Router: URLRequestConvertible {
            
            case Read([String: AnyObject]?)
            case Create([String: AnyObject]?)
            case Update([String: AnyObject]?)
            case Destroy([String: AnyObject]?)
            
            var method: Alamofire.Method {
                switch self {
                case .Create:
                    return .GET
                case .Read:
                    return .GET
                case .Update:
                    return .GET
                case .Destroy:
                    return .GET
                }
            }
            
            var path: String {
                switch self {
                case .Create(let params):
                    return Api.generateURI("/{username}",params: params)
                case .Read(let params):
                    return Api.generateURI("/messages",params: params)
                case .Update(let params):
                    return Api.generateURI("/messages/{id}",params: params)
                case .Destroy(let params):
                    return Api.generateURI("/user/{username}",params: params)
                }
            }
            
            // MARK: URLRequestConvertible
            
            var URLRequest: NSURLRequest {
                switch self {
                case .Create(let parameters):
                    return Alamofire.ParameterEncoding.JSON.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                case .Read(let parameters):
                    return Alamofire.ParameterEncoding.JSON.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                case .Destroy(let parameters):
                    return Alamofire.ParameterEncoding.JSON.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                case .Update(let parameters):
                    return Alamofire.ParameterEncoding.JSON.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                default:
                    return Api.defaultURLRequest(path, method:method)
                }
            }
        }

    }
    

    
    
}