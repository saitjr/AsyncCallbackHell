//
//  Requester.swift
//  AsyncCallbackHell
//
//  Created by tangjr on 6/22/16.
//  Copyright © 2016 saitjr. All rights reserved.
//

import Foundation

enum Result {
    case Success(Any)
    case Failure(RequestError)
}

enum RequestError {
    case Network
    case Server
    
    init(error: AlamoFireError) {
        switch error {
        case .Notfound:
            self = .Server
        case .JsonFormat:
            self = Server
        case .Timeout:
            self = Network
        }
    }
}

typealias Complete = (result: Result) -> Void
typealias AsyncFunc = (para: Any, complete: Complete) -> Void

infix operator +> {associativity left precedence 150}
func +>(lhs: AsyncFunc, rhs: AsyncFunc) -> AsyncFunc {
    return { para, complete in
        lhs(para: para) {
            switch $0 {
            case .Success(let lResult):
                rhs(para: lResult) {
                    switch $0 {
                    case .Success(let rResult):
                        complete(result: .Success([lResult] + [rResult]))
                    case .Failure(let rError):
                        complete(result: .Failure(rError))
                    }
                }
            case .Failure(let lError):
                complete(result: .Failure(lError))
            }
        }
    }
}