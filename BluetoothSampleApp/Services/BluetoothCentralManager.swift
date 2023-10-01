//
//  BluetoothCentralManager.swift
//  BluetoothSampleApp
//
//  Created by kotomi takahashi on 2023/10/01.
//

import UIKit
import CoreBluetooth

/// Bluetooth接続に伴い、ホストとしての統制を行うclass
final class BluetoothCentralManager: NSObject {
    /// Bluetooth接続に伴い、ホストとしての統制を行うclass
    private var centralManager: CBCentralManager?
    
    // スキャンが延長されたか
    private var scanPending = false
    
    // 接続したペリフェラル
    private var peripheral: CBPeripheral?
    
    /// エリア内のperipheralデバイスのスキャン開始
    public func start() {
        // セントラルマネージャーを作成（これによりBluetoothの起動 開始）。
        if centralManager == nil {
            centralManager = CBCentralManager(delegate: self, queue: nil)
        }
        
        // Bluetoothの電源が完全にオンになるまでスキャンを開始できない場合があるため、遅延を想定する必要がある
        guard centralManager?.state == .poweredOn else {
            scanPending = true
            return
        }
        
        // central側のBluetooth機能が準備できていたら、スキャンを開始する
        startScanning()
    }
}

// MARK: - Private -
extension BluetoothCentralManager {
    /// Bluetoothが起動し、準備ができたら、サポートするサービスを宣伝しているペリフェラルをスキャンを開始します。
    fileprivate func startScanning() {
        guard !(centralManager?.isScanning ?? true) else { return }
        
        // ペリフェラルのスキャン開始。
        // scanForPeripherals を呼び出して、利用したいサービスを指定する
        centralManager?.scanForPeripherals(withServices: [BluetoothService.chatID], options: nil)
        // 好きなタイミングで centralManager.isScanning を呼ぶことで、スキャンしているかどうかを確認することができる。
        scanPending = false
    }
    
    /// もし接続が終了した場合、または接続中にエラーが発生した場合、
    /// 最初からやり直せるように、状況を整理
    fileprivate func cleanUp() {
        // ペリフェラルに接続していない場合、またはペリフェラルが接続されていない場合はクリーンアップ(= 通信を切断)をする必要はない。
        guard let peripheral = peripheral,
              peripheral.state != .disconnected else { return }
        // 各サービスのすべての特性をループし、通知されるように構成されたものがあれば、それらを切断します
        peripheral.services?.forEach { service in
            service.characteristics?.forEach { characteristic in
                if characteristic.uuid != BluetoothCharacteristic.chatID { return }
                if characteristic.isNotifying {
                    peripheral.setNotifyValue(false, for: characteristic)
                }
            }
        }
        
        // 通信を切断する。
        centralManager?.cancelPeripheralConnection(peripheral)
    }
}

// MARK: - Central Manager Delegate -
extension BluetoothCentralManager: CBCentralManagerDelegate {
    
    /*
     - centralManagerDidUpdateState は、システム上のBluetoothの状態が変化するたびに呼ばれます。 Bluetoothがリセットされた時や、アクセスが許可されていない場合にも呼ばれます。
     
     - 本番環境では全ての状態を適切に処理する必要がありますが、ここではBluetoothがオンになった状態(powered on)のみ検知するようにします。 その状態になればスキャンを開始することができます。
     */
    /// centralManagerの Bluetoothの状態が変化したときに呼び出される
    /// 主にBluetoothが起動完了したとき呼び出される。
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .unknown:
            print("central の状態が `.unknown` に変更されました")
        case .resetting:
            print("central の状態が `.resetting` に変更されました")
        case .unsupported:
            print("central の状態が `.unsupported` に変更されました")
        case .unauthorized:
            print("central の状態が `.unauthorized` に変更されました")
        case .poweredOff:
            print("central の状態が `.poweredOff` に変更されました")
        case .poweredOn:
            print("central の状態が `.poweredOn` に変更されました")
            if scanPending { startScanning() }
        @unknown default:
            print("central の状態が `an unknown state` に変更されました")
        }
        
        guard central.state == .poweredOn else { return }
        // ペリフェラルのスキャンを開始する
        
    }
    
    /// スキャン中、互換性のあるデバイスが検出されると呼び出される。
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        print("FOUND")
        // 他のペリフェラルは無視
        // TODO: ※ なぜ？
        guard self.peripheral == nil else { return }
        
        // advertisementData には CBAdvertisementDataServiceUUIDsKey に定義された全てのサービスUUIDに加えて、デバイスの名前やメーカー名などのペリフェラルに関する情報が含まれている。
        // CBAdvertisementDataLocalNameKey は通常、ペリフェラルのデバイス名を保持
        if let deviceName = advertisementData[CBAdvertisementDataLocalNameKey] {
            print("Peripheral \(deviceName) discovered.")
        } else {
            print("Compatible device discovered.互換性のあるデバイスが見つかりました。")
        }
        // RSSI = 相対信号強度
        print("RSSI is \(RSSI)")
        
        // ペリフェラルオブジェクトへの強力な参照を保持。
        // そうしないと、接続中に解放されてしまう。
        self.peripheral = peripheral
        
        // サービスIDに一致するペリフェラルを見つけたら、それに接続する。
        centralManager?.connect(peripheral, options: nil)
    }
    
    /// ペリフェラルへの接続を確立できたときに呼び出される。
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        // 接続が確立されたら、スキャンを停止
        centralManager?.stopScan()
        
        // 接続が確立されたので、ペリフェラルからコールバックを受信する
        peripheral.delegate = self
        
        // 欲しいサービスを取得するために、ペリフェラルにクエリを送信
        // クエリの送信に伴い、キャラクタリスティックにアクセスできるようになる。
        peripheral.discoverServices([BluetoothService.chatID])
    }
    
    // ペリフェラルが切断されたときに呼び出される。
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("Peripheral disconnected")
        // ペリフェラルへの参照を削除
        self.peripheral = nil
        //  再度スキャンを開始
        startScanning()
    }
}

// MARK: - Peripheral Delegate -
extension BluetoothCentralManager: CBPeripheralDelegate {
    // ペリフェラルが、指定したIDに一致するサービスを発見できた時呼び出される
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // エラーが発生した場合は、すべての状態をリセット
        if let error = error {
            print("Unable to discover service: \(error.localizedDescription)")
            cleanUp()
            return
        }
        // 複数のサービスがある可能性があるため、それぞれをループして欲しい特性を探す。
        peripheral.services?.forEach { service in
            peripheral.discoverCharacteristics([BluetoothCharacteristic.chatID], for: service)
        }
    }
    
    /// 指定したIDに一致するcharacteristicが、ペリフェラルのサービスで見つかった。
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
            // エラーが発生した場合の処理
            if let error = error {
                print("Unable to discover characteristics: \(error.localizedDescription)")
                cleanUp()
                return
            }
        // 複数の場合に備えてループを実行
        service.characteristics?.forEach { characteristic in
                    guard characteristic.uuid == BluetoothCharacteristic.chatID else { return }

                    // characteristic購読開始。データが送信されたときに通知を受け取る。
                    peripheral.setNotifyValue(true, for: characteristic)
                }
            }
    
    /// characteristicからの通知によって追加のデータが届く。
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
                    print("Characteristic value update failed: \(error.localizedDescription)")
                    return
                }
        // characteristicからペイロードを取得
        let data = characteristic.value
    }
    /// ペリフェラルは、characteristicの購読が成功したかどうかを返す。
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
                    print("Characteristic は通知の更新に失敗した: \(error.localizedDescription)")
                    return
                }
        // このcharacteristicが設定したものであることを確認
        guard characteristic.uuid == BluetoothCharacteristic.chatID else { return }
        // 正常に通知として設定されているか確認
        if characteristic.isNotifying {
                    print("Characteristic notifications が始まったよ.")
                } else {
                    print("Characteristic notifications は止まっている。切断します。")
                    centralManager?.cancelPeripheralConnection(peripheral)
                }
    }
}
