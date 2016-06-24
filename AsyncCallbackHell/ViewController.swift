//
//  ViewController.swift
//  AsyncCallbackHell
//
//  Created by tangjr on 6/22/16.
//  Copyright © 2016 saitjr. All rights reserved.
//

import UIKit

struct User {
    var id: String = ""
    var username: String = ""
}

struct Tweet {
    var id: String = ""
    var title: String = ""
    var publisher: User
}

class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let funcs = login() +> tweet()
        
        funcs(para: []) { result in
            print(result)
        }
    }
}

extension ViewController {
    func login() -> AsyncFunc {
        return { para, comp in
            let alamofire = AlamoFire()
            let para2: [String: Any] = ["username": "admin", "password": "123"]
            
            alamofire.request("login", para: para2) { result, error in
                guard let result2 = result else {
                    let requestError = RequestError(error: error!)
                    comp(result: .Failure(requestError))
                    return
                }
                guard let dic = result2 as? [String: Any], let id = dic["id"] as? String, let username = dic["username"] as? String else {
                    comp(result: .Failure(.Server))
                    return
                }
                let user = User(id: id, username: username)
                comp(result: .Success(user))
            }
        }
    }
    
    func tweet() -> AsyncFunc {
        return { lastResult, comp in
            let alamofire = AlamoFire()
            
            guard let user = lastResult as? User else {
                return
            }
            let para2: [String: Any] = ["id" : user.id, "date" : "2016"]
            
            alamofire.request("tweet", para: para2) { result, error in
                guard let result2 = result else {
                    let requestError = RequestError(error: error!)
                    comp(result: .Failure(requestError))
                    return
                }
                guard let dic = result2 as? [String: Any], let id = dic["id"] as? String, let title = dic["title"] as? String else {
                    comp(result: .Failure(.Server))
                    return
                }
                let tweet = Tweet(id: id, title: title, publisher: user)
                comp(result: .Success(tweet))
            }
        }
    }
}

enum AlamoFireError: Int {
    case Notfound
    case JsonFormat
    case Timeout
}

typealias Callback = (result: Any?, error: AlamoFireError?) -> Void

struct AlamoFire {
    var error: AlamoFireError {
        let randError = Int(arc4random() % 3)
        guard let error = AlamoFireError(rawValue: randError) else {
            return .Notfound
        }
        return error
    }
    
    func request(url: String, para: [String : Any], comp: Callback) {
        let randDelay = Int(arc4random() % 2)
        print("发出请求 \(url)，参数 \(para)")
        self.dispatchSecond(randDelay) {
            let randSuccess = arc4random() % 4 <= 2
            print("\(url) 结果返回")
            if randSuccess {
                comp(result: Server.jsonWithUrl(url), error: nil)
                return
            }
            comp(result: nil, error: self.error)
        }
    }
    
    func dispatchSecond(afterSecond: Int, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(afterSecond) * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}

struct Server {
    static let userJson: [String: Any] = ["id": "1", "username": "admin"]
    static let tweetJson: [String: Any] = ["id": "1", "title": "Swift"]
    
    static func jsonWithUrl(url: String) -> [String: Any] {
        if url == "login" {
            return userJson
        }
        return tweetJson
    }
}