//
//  api.swift
//  realm-todo
//
//  Created by ShoYoshida on 2015/03/31.
//  Copyright (c) 2015年 ShoYoshida. All rights reserved.
//

import Alamofire
import SwiftTask
import URITemplate

typealias ApiResponse = Task<Int,AnyObject,NSError>

protocol ApiDelegate {
    func customReqeust(request: NSMutableURLRequest) -> NSMutableURLRequest
    func onDefaultSuccess(response: AnyObject) -> AnyObject
    func onDefaultFailure(err: NSError) -> NSError
}

class Api {
    
    private struct BaseUrlStringStruct{ static var url = "http://localhost:3000" }
    class var BaseUrlString: String {
        get{ return BaseUrlStringStruct.url }
        set{ BaseUrlStringStruct.url = newValue }
    }

    // workaround tips
    // After updated swift 1.2, use ( static var someVariable: Int = 0 ) instead
    private struct delegateStruct{ static var detegator: ApiDelegate? }
    class var delegate: ApiDelegate? {
        get{ return delegateStruct.detegator }
        set{ delegateStruct.detegator = newValue }
    }
    
    class func defaultURLRequest(let path: String, let method: Alamofire.Method) -> NSMutableURLRequest {
        let URL = NSURL(string: Api.BaseUrlString)!
        let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
        
        mutableURLRequest.HTTPMethod = method.rawValue
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        mutableURLRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let delegate = self.delegate?{
            return delegate.customReqeust(mutableURLRequest)
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
        
        class func request(URLRequest: URLRequestConvertible) -> ApiResponse {
            return ApiResponse {(progress, fulfill, reject, configure) in
                let alam = Alamofire.request(URLRequest)
                                    .validate()
                                    .responseJSON({ (req, res, data, err) -> Void in

                    if let err = err {
                        reject(self.buildErr(res, data: data, err: err))
                        return
                    }
                    fulfill(data!)
                })
                debugPrintln(alam)
                configure.pause  = { [weak alam] in if let alam = alam { alam.suspend() } }
                configure.resume = { [weak alam] in if let alam = alam { alam.resume() }  }
                configure.cancel = { [weak alam] in if let alam = alam { alam.cancel() }  }
            }.then({ (data, errorInfo) -> ApiResponse in
                return ApiResponse { (progress, fulfill, reject, configure) in
                    if(errorInfo == nil){
                        if let delegate = Api.delegate {
                            let newData: AnyObject = delegate.onDefaultSuccess(data!)
                            fulfill(newData)
                            return
                        }
                        fulfill(data!)
                        return
                    }else{
                        let (err, isCancelled) = errorInfo!
                        if let err = err {
                            if let delegate = Api.delegate{
                                let newErr = delegate.onDefaultFailure(err)
                                reject(newErr)
                                return
                            }
                            reject(err)
                            return
                        }
                    }
                }

            })
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
            if let err = err {
                userInfo["originalError"] = err
            }
            var error = NSError(domain: "com.aries.error", code: -1, userInfo: userInfo)
            return error
        }
        
    }
        
    class TodoItem: Base {
        
        // case nil object
        class func Read() -> ApiResponse {
            var params: [String: AnyObject]? = nil
            return request(Router.Read(params))
        }
        
        // case with all template param
        class func Create(name: String, finished: Bool = false) -> ApiResponse {
            var params = [String: AnyObject]()
            
            var todo = [String: AnyObject]()
            todo["name"] = name
            todo["finished"]  = finished
            
            params["todo"] = todo
            
            return request(Router.Create(params))
        }
        
        // case with chipped template param
        class func Show(id: Int) -> ApiResponse {
            var params = [String: AnyObject]()
            
            params["id"] = id
            
            return request(Router.Show(params))
        }
        
        class func Update(id: Int, name: String, finished: Bool) -> ApiResponse {
            var params = [String: AnyObject]()
            
            var todo = [String: AnyObject]()
            todo["id"]        = id
            todo["name"]      = name
            todo["finished"]  = finished
            
            params["id"] = id
            
            params["todo"] = todo
            
            return request(Router.Update(params))
        }
        
        private enum Router: URLRequestConvertible {
            
            case Read([String: AnyObject]?)
            case Create([String: AnyObject]?)
            case Show([String: AnyObject]?)
            case Update([String: AnyObject]?)
            
            var method: Alamofire.Method {
                switch self {
                case .Create:
                    return .POST
                case .Read:
                    return .GET
                case .Show:
                    return .GET
                case .Update:
                    return .PUT
                }
            }
            
            var path: String {
                switch self {
                case .Create(let params):
                    return Api.generateURI("/todos",params: params)
                case .Read(let params):
                    return Api.generateURI("/todos",params: params)
                case .Show(let params):
                    return Api.generateURI("/todos/{id}",params: params)
                case .Update(let params):
                    return Api.generateURI("/todos/{id}",params: params)
                }
            }
            
            // MARK: URLRequestConvertible
            
            var URLRequest: NSURLRequest {
                switch self {
                case .Create(let parameters):
                    return Alamofire.ParameterEncoding.JSON.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                case .Read(let parameters):
                    return Alamofire.ParameterEncoding.URL.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                case .Update(let parameters):
                    return Alamofire.ParameterEncoding.JSON.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                case .Show(let parameters):
                    return Alamofire.ParameterEncoding.URL.encode(Api.defaultURLRequest(path, method: method), parameters: parameters).0
                default:
                    return Api.defaultURLRequest(path, method:method)
                }
            }
        }

    }
    

    
    
}