//
//  api.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/31.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import Alamofire
import SwiftyJSON

class Api {
    
    class TodoItem {
        
        class func Read(username: String) -> Request {
            return Alamofire.request(Api.ToDoItemRouter.Read(username))
        }
        
        class func Create(params: [String: AnyObject]) -> Request {
            return Alamofire.request(Api.ToDoItemRouter.Create(params))
        }
        
    }
    
    enum ToDoItemRouter: URLRequestConvertible {
        static let baseURLString = "http://www.mocky.io"
        static var OAuthToken: String?
        
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
                return "/users/\(username)"
            case .Destroy(let username):
                return "/users/\(username)"
            }
        }
        
        // MARK: URLRequestConvertible
        
        var URLRequest: NSURLRequest {
            let URL = NSURL(string: ToDoItemRouter.baseURLString)!
            let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
            mutableURLRequest.HTTPMethod = method.rawValue
            
            if let token = ToDoItemRouter.OAuthToken {
                mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            switch self {
            case .Create(let parameters):
                return Alamofire.ParameterEncoding.JSON.encode(mutableURLRequest, parameters: parameters).0
            case .Update(_, let parameters):
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            default:
                return mutableURLRequest
            }
        }
    }
    
    
}