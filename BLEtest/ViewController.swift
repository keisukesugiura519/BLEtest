//
//  ViewController.swift
//  BLEtest
//
//  Created by 杉浦圭相 on 2018/06/04.
//  Copyright © 2018年 杉浦圭相. All rights reserved.
//

import UIKit
import CoreBluetooth

class ViewController: UIViewController, CBPeripheralManagerDelegate {
    
    var peripheralManager: CBPeripheralManager!
    @IBOutlet var advBtn: UIButton!
    @IBOutlet var label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //  peripheralManagerを初期化
        peripheralManager = CBPeripheralManager(delegate: nil, queue: nil, options: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // ペリフェラルマネージャーが変化すると呼ばれる
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("state: \(peripheral.state)")
        
        switch peripheral.state {
        case .poweredOn:
            // アドバタイズ開始
            advstart()
        default:
            break
        }
    }
    
    // アドバタイズスタート用関数宣言
    private func advstart() {
        // アドバタイズメントデータを作成する
        let advData = [CBAdvertisementDataLocalNameKey: "Test Device"]
        // アドバタイズスタート
        peripheralManager.startAdvertising(advData)
        advBtn.setTitle("STOP ADVERTISING", for: .normal) // ボタンタイトル変更
    }
    
    private func advstop() {
        // アドバタイズストップ
        peripheralManager.stopAdvertising()
        advBtn.setTitle("START ADVERTISING", for: .normal) // ボタンタイトル変更
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            label.text = "ERROR"
            print("アドバタイズ開始失敗! error: \(error)")
            return
        } else {
            label.text = "SUCCESS"
            print("アドバタイズ開始成功！")
        }
    }
    
    @IBAction func advBtnTapped(sender: UIButton) {
        if !peripheralManager.isAdvertising {
            advstart()
        } else {
            advstop()
        }
    }
}

