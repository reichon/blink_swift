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
    @IBOutlet weak var BrainMode: UILabel!
    @IBOutlet weak var SleepProgress: UIProgressView!
    @IBOutlet weak var SleepProgressView: UILabel!
    @IBOutlet weak var StopMusic: UIButton!
    
    //瞬き回数
    var blinkCnt = 0
    var count = 0
    
    var msecs : [Float] = []
    var freq : Float = 0.0
    
    var KSS = 0
    
    var timer: NSTimer?
    var startDate: NSDate?
    
    
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
//        startDate = NSDate()
//        timer = NSTimer.scheduledTimerWithTimeInterval(
//            1, // 秒
//            target: self,
//            selector: #selector(timerDidFire),
//            userInfo: nil,
//            repeats: true
//        )
//    }

    override func viewDidAppear(animated: Bool) {
        startDate = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(
            1, // 秒
            target: self,
            selector: #selector(memeRealTimeModeDataReceived),
            userInfo: nil,
            repeats: true
        )
    }
    
//    func timerDidFire(_: NSTimer) {
//        guard let d = startDate?.timeIntervalSinceNow where d < 5 * 60 else {
//            print("5分経った")
//            timer?.invalidate()
//            return
//        }
//        
//        print("まだ5分じゃない")
//        
//    }
    
    @IBAction func TapButton(sender: UILongPressGestureRecognizer) {
        if(sender.state == UIGestureRecognizerState.Ended){
            player1.stop()
        }
    }
    
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
    

    
    func memeRealTimeModeDataReceived(data: MEMERealTimeData!, _: NSTimer) {
        
        var sum : Float = 0.0
        
        guard let d = startDate?.timeIntervalSinceNow where d < 5 * 60 else {
            print("5分経った")
            timer?.invalidate()
            return
        }
        
        print("まだ5分じゃない")

        msecs += [Float(data.blinkSpeed)]
        
        if Float(data.blinkSpeed) < 70 {
            msecs.removeLast()
        }
        
        if msecs.count > 5 {
            for msec in msecs{
                sum += msec
            }
            
            freq = sum / Float(msecs.count)
            
        } else if msecs.count == 10 {
            msecs.removeFirst()
        }
        
        
//        if freq > 90.0 && freq < 108.0 {
//            KSS = 1
//        } else if freq > 108.0 && freq < 112.0 {
//            KSS = 2
//        } else if freq >= 112.0 && freq < 114.0 {
//            KSS = 3
//        } else if freq >= 114.0 && freq < 116.0 {
//            KSS = 4
//        } else if freq >= 116.0 && freq < 119.0 {
//            KSS = 5
//        } else if freq >= 119.0 && freq < 121.0 {
//            KSS = 6
//        } else if freq >= 121.0 && freq < 135.0 {
//            KSS = 7
//        } else if freq >= 135.0 && freq < 145.0 {
//            KSS = 8
//        } else if freq >= 145.0 && freq < 155.0 {
//            KSS = 9
//        }
        
        print(data.blinkSpeed, data.blinkStrength, msecs.count, freq)
        
        let speechUtterance = AVSpeechUtterance(string: BrainMode.text!)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        
//        if freq >= 100.0 {
//            SleepProgress.setProgress((freq - 100.0) / 100.0, animated: true)
//            blinkCnt += 1
//            SleepProgressView.text = String((freq - 100.0))
//        }

        guard freq >= 100.0 else {
            BrainMode.text = "計測中"
            return
        }
        
        SleepProgress.setProgress((freq - 100.0) / 100.0, animated: true)
        blinkCnt += 1
        SleepProgressView.text = String((freq - 100.0))
        
        if freq < 160.0 {
            BrainMode.text = "警戒状態です"
            player1.stop()
        } else if freq >= 160.0 && freq < 180.0 {
            BrainMode.text = "窓を開けたりガムを噛むと良いですよ"
            speech.speakUtterance(speechUtterance)
            player1.stop()
        } else if freq >= 180.0 {
            BrainMode.text = "今すぐ休憩してください"
            speech.speakUtterance(speechUtterance)
            player1.skipToNextItem()
            player1.play()
        }
        
//        switch KSS {
//        case 1,2,3,4,5:
//            BrainMode.text = "警戒状態です"
//            player1.stop()
//        case 6,7:
//            BrainMode.text = "窓を開けたりガムを噛むと良いですよ"
//            speech.speakUtterance(speechUtterance)
//            player1.stop()
//        case 8,9:
//            BrainMode.text = "今すぐ休憩してください"
//            speech.speakUtterance(speechUtterance)
//            player1.skipToNextItem()
//            player1.play()
//        default:
//            BrainMode.text = "計測中"
//            speech.speakUtterance(speechUtterance)
//            break
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