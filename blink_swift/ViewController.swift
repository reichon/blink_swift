//
//  ViewController.swift
//  blink_swift
//
//  Created by Rei K on 2016/06/29.
//  Copyright © 2016年 Rei K. All rights reserved.
//

import UIKit

class ViewController: UIViewController, MEMELibDelegate {
    //瞬き回数
    var blinkCnt = 0;
    
    //瞬き検知した回数を表示
    @IBOutlet weak var lblBlinkCnt: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
    }
    
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connectPeripheral(peripheral)
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        print(data.description)
        
        if data.blinkSpeed > 1000 {
            print("you are in alert mode");
        } else {
            print("sleep mode");
        }
    }

}

