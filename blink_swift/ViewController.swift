//
//  ViewController.swift
//  blink_swift
//
//  Created by Rei K on 2016/06/29.
//  Copyright © 2016年 Rei K. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox
import CoreBluetooth
import MediaPlayer

class ViewController: UIViewController, UIGestureRecognizerDelegate, MEMELibDelegate {
    
    
    //瞬き検知した回数を表示
    @IBOutlet weak var lblBlinkCnt: UILabel!
    @IBOutlet weak var BrainMode: UILabel!
    @IBOutlet weak var SleepProgress: UIProgressView!
    @IBOutlet weak var SleepProgressView: UILabel!
    @IBOutlet weak var StopMusic: UIButton!
    
    //瞬き回数
    var blinkCnt = 0
    var count = 0
    
    //    let player =
    let player1 = MPMusicPlayerController.applicationMusicPlayer()
    let speech = AVSpeechSynthesizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MEMELib.sharedInstance().delegate = self
        
        let query = MPMediaQuery.songsQuery()
        
        guard let songs = query.items else {
            print("song not found")
            return
        }
        
        let index = Int(arc4random_uniform(UInt32(songs.count)))
        let song = songs[index]
        
        player1.setQueueWithQuery(query)
        player1.nowPlayingItem = song
    }
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        let query = MPMediaQuery.songsQuery()
//        
//        guard let songs = query.items else {
//            print("song not found")
//            return
//        }
//        
//        let index = Int(arc4random_uniform(UInt32(songs.count)))
//        let song = songs[index]
//        
//        let player1 = MPMusicPlayerController.applicationMusicPlayer()
//        player1.setQueueWithQuery(query)
//        player1.nowPlayingItem = song
//    }
    
    func memeAppAuthorized(status: MEMEStatus) {
        MEMELib.sharedInstance().startScanningPeripherals()
    }
    
    func memePeripheralFound(peripheral: CBPeripheral!, withDeviceAddress address: String!) {
        MEMELib.sharedInstance().connectPeripheral(peripheral)
    }
    
    func memePeripheralConnected(peripheral: CBPeripheral!) {
        print("device connected")
        let status = MEMELib.sharedInstance().startDataReport()
        print(status)
    }
    
    func checkMEMEStatus(status:MEMEStatus) {
        switch status {
        case MEME_OK:
            print("Status: MEME_OK")
        case MEME_ERROR_BL_OFF:
            let alert = UIAlertController(title: "App Auth Failed", message: "Invalid Application ID or Client Secret", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        default:
            let alert = UIAlertController(title: "Error", message: "sonota", preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!) {
        print(data.blinkSpeed, data.blinkStrength, data.accY)
        
        let speechUtterance = AVSpeechUtterance(string: BrainMode.text!)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
        if Float(data.blinkSpeed) > 0 {
            SleepProgress.setProgress((Float(data.blinkSpeed) - 147.0) / 100.0, animated: true)
            blinkCnt += 1
            SleepProgressView.text = String(Float(data.blinkSpeed) - 147.0)
        }
        
        lblBlinkCnt.text = String(blinkCnt)
        
//        if Double(data.blinkSpeed) < 208.31 {
//            BrainMode.text = "you are in ALERT mode";
//            player?.stop()
//        } else if Double(data.blinkSpeed) > 251.9{
//            BrainMode.text = "you are in SLEEP mode";
//            player?.currentTime = 0
//            player?.play()
//        }
        
        if Float(data.blinkSpeed) > 147.0 && Float(data.blinkSpeed) < 157.0 {
            BrainMode.text = "警戒状態です"
            player1.stop()
        } else if Float(data.blinkSpeed) > 230.0{
            BrainMode.text = "今すぐ休憩してください"
            speech.speakUtterance(speechUtterance)
            player1.skipToNextItem()
            player1.play()
        } else if Float(data.blinkSpeed) > 180.0{
            BrainMode.text = "窓を開けましょう"
            speech.speakUtterance(speechUtterance)
            player1.stop()
        }
        
//        if Float(data.blinkSpeed) > 80.0 && Float(data.blinkSpeed) < 120.0 {
//            BrainMode.text = "警戒状態です"
//        } else if Float(data.blinkSpeed) > 180.0 {
//            BrainMode.text = "今すぐ休憩してください"
//            speech.speakUtterance(speechUtterance)
//            player1.skipToNextItem()
//            player1.play()
//        } else if Float(data.blinkSpeed) > 140.0{
//            BrainMode.text = "窓を開けましょう"
//            speech.speakUtterance(speechUtterance)
//        }
        
        // 頭が下を向いていたら忠告
//        if data.accY > 7 {
//            AudioServicesPlaySystemSound(1108)
//        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}