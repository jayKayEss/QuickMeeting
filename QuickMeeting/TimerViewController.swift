//
//  ViewController.swift
//  QuickMeeting
//
//  Created by Justin Sheckler on 5/16/15.
//  Copyright (c) 2015 Justin Sheckler. All rights reserved.
//

import UIKit
import AVFoundation

class TimerViewController: UIViewController, CountdownTimerDelegate, AVSpeechSynthesizerDelegate {

    var timer: CountdownTimer?
    var duration: CFTimeInterval = 0
    var interval: CFTimeInterval = 0
    var displayTimer: NSTimer?
    var speechSynth: AVSpeechSynthesizer?
    var bellSound: SystemSoundID = 0
    var isSpeaking: Bool = false
    
    @IBOutlet weak var displayLabel: UILabel?
    
    override func viewDidLoad() {
        UIApplication.sharedApplication().idleTimerDisabled = false;
        UIApplication.sharedApplication().idleTimerDisabled = true;
        
        super.viewDidLoad()
        timer = CountdownTimer(duration: duration, interval: interval, delegate: self)

        updateDisplay()
        displayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self,
            selector: "updateDisplay", userInfo: nil, repeats: true)
        
        timer?.start()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        AudioServicesDisposeSystemSoundID(bellSound)
        bellSound = 0
        speechSynth = nil
    }
    
    override func viewWillDisappear(animated: Bool) {
        timer?.stop()
        displayTimer?.invalidate()
        UIApplication.sharedApplication().idleTimerDisabled = false;
    }
    
    func updateDisplay() {
        if let timeRemaining = timer?.timeRemaining {
            displayLabel?.text = String(format: "%02d:%02d", timeRemaining.mins, timeRemaining.secs)
        }
    }
    
    func saySomething(text: String) {
        if (isSpeaking) {
            NSLog("Refusing to queue speech while speaking")
            return
        }
        
        isSpeaking = true
        
        if (bellSound == 0) {
            if let audioUrl = NSBundle.mainBundle().URLForResource("bell", withExtension: "aiff") {
                AudioServicesCreateSystemSoundID(audioUrl, &bellSound)
            }
        }

        if (speechSynth == nil) {
            speechSynth = AVSpeechSynthesizer()
            weak var weakSelf = self
            speechSynth?.delegate = weakSelf
        }
        
        AudioServicesPlaySystemSound(bellSound);
        let utterance = AVSpeechUtterance(string: text)
        utterance.rate = AVSpeechUtteranceDefaultSpeechRate * 0.1
        utterance.preUtteranceDelay = 0.5
        speechSynth?.speakUtterance(utterance)
    }
    
    func onStart(timeRemaining: CFTimeInterval) {
        saySomething(String(format: "Starting a %d minute meeting", timeRemaining.mins))
    }
    
    func onStop() {
        saySomething("The meeting is over")
        displayTimer?.invalidate()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func onInterval(timeRemaining: CFTimeInterval) {
        let text = String(format: "We have %d minutes left", timeRemaining.mins)
        saySomething(text)
    }
    
    @IBAction func speakNow() {
        onInterval(timer!.timeRemaining)
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        NSLog("Finished speaking")
        isSpeaking = false
    }
    
}

