//
//  AppDelegate.swift
//  SocketLogger
//
//  Created by ntoworks on 2022/06/24.
//

import UIKit
import AVFoundation

@main
class AppDelegate: UIResponder, UIApplicationDelegate, AVAudioPlayerDelegate {

    var window: UIWindow? = nil
    var audioPlayer: AVAudioPlayer?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        prepareAudio()
        return true
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        print("applicationDidBecomeActive")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        print("applicationWillEnterForeground")
//        audioPlayer?.stop()
    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
//        audioPlayer?.play()
    }
    
    func prepareAudio() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers, .allowAirPlay])
            print("Playback OK")
            try AVAudioSession.sharedInstance().setActive(true)
            print("Session is Active")
        } catch {
            print(error)
        }

        if let filePath = Bundle.main.path(forResource: "nonesound", ofType: "mp3") {
        
        let url = URL.init(fileURLWithPath: filePath)
            do {
                try audioPlayer = AVAudioPlayer(contentsOf: url)
                audioPlayer?.delegate = self
                //audioPlayer?.volume = 0.1
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("audioPlayer error \(error.localizedDescription)")
            }
        } else {
            print("file not found")
        }

    }
    
    // 재생에 관련된 알림 델리게이트 메서드
    // 사운드 재생이 끝나면 호출됨
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        prepareAudio()
    }
    // 재생중에 디코딩 에러가 발생하면 호출됨
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        
    }

}

