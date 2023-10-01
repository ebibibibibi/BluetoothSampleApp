//
//  BluetoothService.swift
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
    static let chatServiceID = CBUUID(string: "42332fe8-9915-11ea-bb37-0242ac130002")
}
