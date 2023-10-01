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
    
    // チャットデータのフローを制御するサービス内のcharacteristic
    private var characteristic: CBMutableCharacteristic?
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
                                             CBAdvertisementDataServiceUUIDsKey: [BluetoothService.chatID]]
        
        peripheralManager?.startAdvertising(advertisementData)
        advertPending = false
    }
}

extension BluetoothPeripheralManager: CBPeripheralManagerDelegate {
    /// Bluetoothがどの状態に入ったかを表示
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
        // 電源がオンになったら、ペリフェラルをサポートするサービスとキャラクタリスティックを構成
        guard peripheral.state == .poweredOn else { return }
        
        characteristic = CBMutableCharacteristic(type: BluetoothCharacteristic.chatID,
                                                 properties: .notify,
                                                 value: nil,
                                                 permissions: .writeable)
        // キャラクタリスティックを表現するサービスを作成
        let service = CBMutableService(type: BluetoothService.chatID, primary: true)
        service.characteristics = [self.characteristic!]
        // ペリフェラルにこのサービスを登録
        peripheralManager?.add(service)
        // Bluetoothがセットアップを開始する前に、すでにアドバタイズのリクエストを行っていた場合、開始する。
        if advertPending {
            startAdvertising()
        }
    }
}
