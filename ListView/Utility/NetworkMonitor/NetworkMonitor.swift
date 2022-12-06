//
//  NetworkMonitor.swift
//  NetworkLayer
//
//  Created by Macbook on 23/11/22.
//


import Network
import Foundation


final class NetworkMonitor {

    // MARK: - Properties
    static var shared  = NetworkMonitor()

    private let monitor = NWPathMonitor()
    private var status = NWPath.Status.requiresConnection

    public var isCellular: Bool = true
    public var isReachable: Bool { status == .satisfied }


    // MARK: - Private Initializer
    private init() {}
}

extension NetworkMonitor {
    // MARK: - Monitor Network Connection
    
    public func startMonitoring() {

        monitor.pathUpdateHandler = { [weak self] path in

            self?.status = path.status
            self?.isCellular = path.isExpensive

            if path.status == .satisfied {
                if path.usesInterfaceType(.wifi) {
                    print("We're connected over Wifi!")
                } else if path.usesInterfaceType(.cellular) {
                    print("We're connected over Cellular!")
                } else {
                    print("We're connected over other network!")
                }
            } else {
                print("No connection.")
                // post disconnected notification
            }
        }

        let queue = DispatchQueue.global(qos: .background)
        monitor.start(queue: queue)
    }

    public func stopMonitoring() {
        monitor.cancel()
    }
}


