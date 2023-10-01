//
//  BluetoothConstants.swift
//  BluetoothSampleApp
//
//  Created by kotomi tahkahashi on 2023/10/01.
//

import Foundation
import CoreBluetooth

/// アドバタイズ = ペリフェラル機器が「僕はここにいるよ」ということを伝える為の無線信号。
/// １対１の通信ではなく、不特定多数の相手にデータを送信する一方通行の通信方式
///
/// Bluetoothデバイスは、その独自に識別されるサービスとして、
/// （例：心拍モニター、温度計などの）能力をブロードキャストします。
/// 弊社のチャットアプリでは、独自のサービスとそのサービスIDを定義します。
/// これにより、スキャン時に検出できるようにします。
struct BluetoothService {
    // TODO: CBUUIDを後ほど設定する
    static let chatID = CBUUID(string: "")
}


/// Bluetoothサービスには、サービスの特定の機能を表す多くの特性が含まれています。この例では、チャットサービスにはデバイス間でデータを移動するために使用される特性が含まれます。
struct BluetoothCharacteristic {
    // TODO: CBUUIDを後ほど設定する
    static let chatID = CBUUID(string: "")
}
