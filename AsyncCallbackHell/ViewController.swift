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
        
        let funcs = login() +> tweetList()
        
        funcs(para: ["username" : "admin", "password" : "123"]) { result in
            print(result)
        }
    }
    
    func dispatchSecond(afterSecond: Int, block: dispatch_block_t) {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(afterSecond) * Int64(NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue(), block)
    }
}

extension ViewController {
    func login() -> AsyncFunc {
        return { para, comp in
            self.dispatchSecond(1) {
                print("login 请求参数 \(para)")
                let rand = arc4random() % 4 <= 2
                if rand {
                    let user = User(id: "1", username: "admin")
                    comp(result: .Success(user))
                } else {
                    comp(result: .Failure(.Network))
                }
            }
        }
    }
    
    func tweetList() -> AsyncFunc {
        return { result, comp in
            self.dispatchSecond(1) {
                let user = result as! User
                let para2 = ["id" : user.id, "date" : "2016"]
                print("tweet 请求参数 \(para2)")
                let rand = arc4random() % 4 <= 2
                if rand {
                    let user = User(id: "1", username: "admin")
                    let tweet = Tweet(id: "1", title: "Swift", publisher: user)
                    comp(result: .Success(tweet))
                } else {
                    comp(result: .Failure(.Network))
                }
            }
        }
    }
}