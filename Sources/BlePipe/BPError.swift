//
//  File.swift
//  
//
//  Created by zhiou on 2021/8/9.
//

import Foundation

public enum BPError: Error {
    case timeout
    case notFound
    case alreadyConnected
    case alreadyConnecting
    case alreadyDisconnected
    case sysError(Error?)
    case noPipeEnd
}
