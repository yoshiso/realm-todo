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


class Api {
    
    typealias ApiRequest = Task<Int,JSON,NSError>
    
    // workaround tips 
    // After updated swift 1.2, use ( static var someVariable: Int = 0 ) instead
    private struct OAuthTokenStruct{ static var token: String? }
    class var OAuthToken: String? {
        get{ return OAuthTokenStruct.token }
        set{ OAuthTokenStruct.token = newValue }
    }
    private struct BaseUrlStringStruct{ static var url = "http://www.mocky.io" }
    class var BaseUrlString: String {
        get{ return BaseUrlStringStruct.url }
        set{ BaseUrlStringStruct.url = newValue }
    }
    
    class func request(URLRequest: URLRequestConvertible) -> ApiRequest {
        return ApiRequest {(progress, fulfill, reject, configure) in
            let alam = Alamofire.request(URLRequest).responseJSON({ (req, res, data, err) -> Void in
                if let err = err {
                    println("ERROR: \(err)")
                    reject(err)
                    return
                }
                let json = JSON(data!)
                println("Response: ")
                println(json)
                fulfill(json)
            })
            configure.pause  = { alam.suspend() }
            configure.resume = { alam.resume()  }
            configure.cancel = { alam.cancel()  }
        }
    }
    
    class TodoItem {
        
        
        class func Read(username: String) -> ApiRequest {
            return Api.request(Api.ToDoItemRouter.Read(username))
        }
        
        class func Create(params: [String: AnyObject]) -> ApiRequest {
            return Api.request(Api.ToDoItemRouter.Create(params))
        }
        
        class func Update(username: String, params: [String: AnyObject]) -> ApiRequest {
            return Api.request(Api.ToDoItemRouter.Update(username, params))
        }
        
    }
    
    enum ToDoItemRouter: URLRequestConvertible {

        case Create([String: AnyObject])
        case Read(String)
        case Update(String, [String: AnyObject])
        case Destroy(String)
        
        var method: Alamofire.Method {
            switch self {
            case .Create:
                return .POST
            case .Read:
                return .GET
            case .Update:
                return .PUT
            case .Destroy:
                return .DELETE
            }
        }
        
        var path: String {
            switch self {
            case .Create:
                return "/v2/551a34139650aa38160a97e0"
            case .Read(let username):
                return "/v2/551a41899650aa84170a97e7"
            case .Update(let username, _):
                return "/v2/551a41899650aa84170a97e7"
            case .Destroy(let username):
                return "/users/\(username)"
            }
        }
        
        // MARK: URLRequestConvertible
        
        var URLRequest: NSURLRequest {
            let URL = NSURL(string: Api.BaseUrlString)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            if let token = Api.OAuthToken {
                mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            switch self {
            case .Create(let parameters):
                return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            case .Update(_, let parameters):
                return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            default:
                return mutableURLRequest
            }
        }
    }
    
    
}