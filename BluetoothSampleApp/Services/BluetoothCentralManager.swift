//
//  BluetoothCentralManager.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/01.
//

import UIKit
import CoreBluetooth

/// Bluetooth接続に伴い、統制の役割を有するclass
final class BluetoothCentralManager: NSObject {

    private var centralManager: CBCentralManager!

    override init() {
        super.init()
        /// Bluetooth接続のセットアップ
        centralManager = CBCentralManager(delegate: self, queue: nil)

    }

    public func start() {
        // 機器を検出
        centralManager.scanForPeripherals(withServices: [BluetoothService.chatServiceID], options: nil)
    }
}

extension BluetoothCentralManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {

    }
}
