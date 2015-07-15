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

    let TimerRestorationID = "CountdownTimerRestorationID"
    
    var timer: CountdownTimer?
    var duration: CFTimeInterval = 0
    var interval: CFTimeInterval = 0
    var displayTimer: NSTimer?
    var speechSynth: AVSpeechSynthesizer?
    var bellSound: SystemSoundID = 0
    var isSpeaking: Bool = false
    
    @IBOutlet weak var displayLabel: UILabel?
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        NSLog("View Will Appear!")
        UIApplication.sharedApplication().idleTimerDisabled = false;
        UIApplication.sharedApplication().idleTimerDisabled = true;
        
        if (timer == nil) {
            timer = CountdownTimer()
            timer?.start(duration, interval: interval, delegate: self)
        } else {
            if !timer!.isTimeRemaining {
                timer!.stop()
                goBackToRootViewController()
                return
            }
        }

        updateDisplay()
        displayTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self,
            selector: "updateDisplay", userInfo: nil, repeats: true)
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
        timer = nil
        displayTimer?.invalidate()
        UIApplication.sharedApplication().idleTimerDisabled = false;
    }
    
    func updateDisplay() {
        let timeRemaining = timer!.timeRemaining
        displayLabel?.text = String(format: "%02d:%02d", timeRemaining.mins, timeRemaining.secs)
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
        saySomething(String(format: "Let's meet for %d minutes", timeRemaining.mins))
    }
    
    func onStop(timeRemaining: CFTimeInterval) {
        saySomething(timeRemaining.description)
        goBackToRootViewController()
    }
    
    func onInterval(timeRemaining: CFTimeInterval) {
        saySomething(timeRemaining.description)
    }
    
    func goBackToRootViewController() {
        displayTimer?.invalidate()
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    @IBAction func speakNow() {
        onInterval(timer!.timeRemaining)
    }

    func speechSynthesizer(synthesizer: AVSpeechSynthesizer!, didFinishSpeechUtterance utterance: AVSpeechUtterance!) {
        NSLog("Finished speaking")
        isSpeaking = false
    }
    
    override func encodeRestorableStateWithCoder(coder: NSCoder) {
        NSLog("### Encoding state...")
        coder.encodeObject(timer, forKey: TimerRestorationID)
        super.encodeRestorableStateWithCoder(coder)
    }
    
    override func decodeRestorableStateWithCoder(coder: NSCoder) {
        NSLog("### Decoding state...")
        timer = coder.decodeObjectForKey(TimerRestorationID) as? CountdownTimer
        NSLog("Timer: %@", timer!)
        timer?.delegate = self
        super.decodeRestorableStateWithCoder(coder)
    }
}

