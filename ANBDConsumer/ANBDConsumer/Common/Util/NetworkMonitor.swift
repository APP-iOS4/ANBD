//
//  NetworkMonitor.swift
//  ANBDConsumer
//
//  Created by 최주리 on 5/1/24.
//

import Foundation
import Network
import UIKit
import SwiftUI

final class NetworkMonitor: ObservableObject {
    private let queue = DispatchQueue(label: "Monitor")
    private let monitor = NWPathMonitor()
    
    @Published var isConnected = true
    
    init() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async {
                self.isConnected = path.status == .satisfied
            }
        }
        
        monitor.start(queue: queue)
    }
}
