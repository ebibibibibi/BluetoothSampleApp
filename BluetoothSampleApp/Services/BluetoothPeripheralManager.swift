//
//  BluetoothPeripheralManager.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/01.
//

import Foundation
import CoreBluetooth

/// Bluetooth接続に伴い、クライアントとしての統制を行うclass
final class BluetoothPeripheralManager: NSObject {

    // ペリフェラルの状態を管理する Core Bluetooth object
    private var peripheralManager: CBPeripheralManager?

    // アドバタイズが延長されているかどうか
    private var advertPending = false

    public func start() {
        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }

        guard peripheralManager?.state == .poweredOn else {
            advertPending = true
            return
        }

        startAdvertising()
    }
}

extension BluetoothPeripheralManager {
    private func startAdvertising() {
        guard !(peripheralManager?.isAdvertising ?? true) else { return }

        let advertisementData: [String: Any] = [CBAdvertisementDataLocalNameKey: "XD",
                                                 CBAdvertisementDataServiceUUIDsKey: [BluetoothService.chatServiceID]]

        peripheralManager?.startAdvertising(advertisementData)
        advertPending = false
    }
}

extension BluetoothPeripheralManager: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            print("peripheralの状態が `.unknown` に変更されました")
        case .resetting:
            print("peripheralの状態が `.resetting` に変更されました")
        case .unsupported:
            print("peripheralの状態が `.unsupported` に変更されました")
        case .unauthorized:
            print("peripheralの状態が `.unauthorized` に変更されました")
        case .poweredOff:
            print("peripheralの状態が `.poweredOff` に変更されました")
        case .poweredOn:
            print("peripheralの状態が `.poweredOn` に変更されました")
            if advertPending { startAdvertising() }
        @unknown default:
            print("peripheralの状態が`an unknown state`に変更されました")
        }
    }
}
