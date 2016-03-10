//
//  ViewController.swift
//  Sets
//
//  Created by Guy Daher on 10/11/15.
//  Copyright © 2015 guydaher. All rights reserved.
//

import UIKit
import SCLAlertView
import AVFoundation

class GameViewController: UIViewController {
    
    var timeCount = 0 {
        didSet {
            var elapsedTime: NSTimeInterval = Double(timeCount)
            
            //calculate the minutes in elapsed time.
            let minutes = UInt8(elapsedTime / 60.0)
            elapsedTime -= (NSTimeInterval(minutes) * 60)
            
            //calculate the seconds in elapsed time.
            let seconds = UInt8(elapsedTime)
            elapsedTime -= NSTimeInterval(seconds)
            
            
            let strMinutes = String(format: "%02d", minutes)
            let strSeconds = String(format: "%02d", seconds)
            
            //concatenate minuets, seconds and milliseconds as assign it to the UILabel
            timeLabel.text = "\(strMinutes):\(strSeconds)"
        }
    }
    
    var numberOfSetsCompleted = 0 {
        didSet {
            setCompletedLabel.text = "Sets Completed: \(numberOfSetsCompleted)"
        }
    }
    
    // TODO: Refactor these 2 into a Class for better abstraction
    var brain: CardSetBrain!
    var cardViews = [Int:UIButton]()
    
    var timer = NSTimer()
    var timerModeCountSec = 60

    var gameMode = GameMode.ClassicSet81
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var setCompletedLabel: UILabel!
    
    var audioPlayer = AVAudioPlayer()
    
    let TOTAL_NUMBER_OF_CARDS_ON_SCREEN = 12
    
    // TODO: Refactor these 2 into a Class for better abstraction
    var totalNumberOfHintsUsed = 0
    var numberOfHintsShownOnScreen = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setBackgroundImageWithImageNamed("pool_table")
        
        startGame()
    }
    
    private func setBackgroundImageWithImageNamed(imageName: String) {
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "pool_table")!)
    }
    
    func startGame() {
        brain = CardSetBrain(gameMode: self.gameMode) // self.gameMode is set from the MainMenuViewController
        initializecardViewsFromButtonsInView()
        initializeTimerCoutValue()
        resumeTimer()
        numberOfSetsCompleted = 0
        totalNumberOfHintsUsed = 0
        numberOfHintsShownOnScreen = 0
        
        #if DEBUG
            showHintSetOnScreen()
        #endif
    }
    
    @IBAction func PauseClicked(sender: UIButton) {
        pauseTimer()
        launchPauseAlertView()
    }
    
    @IBAction func HintClicked(sender: UIButton) {
        if numberOfHintsShownOnScreen == 2 {
            let alertView = SCLAlertView()
            alertView.showCloseButton = true
            alertView.showInfo("No More Hints!", subTitle: "I already gave you 2 hints... you can find the last card!")
        }
        else {
            numberOfHintsShownOnScreen++
            totalNumberOfHintsUsed++
            self.showHintSetOnScreen(numberOfHintsShownOnScreen)
        }
    }
    
    private func launchPauseAlertView() {
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("Main Menu", target:self, selector:Selector("goToMainMenu"))
        alertView.addButton("Restart", target:self, selector:Selector("resetRound"))
        alertView.addButton("Resume") {
            alertView.dismissViewControllerAnimated(true, completion: nil)
            self.resumeTimer()
        }
        
        alertView.showInfo("Pause", subTitle: "Choose one of the following")
    }
    
    func roundCompleteAlert() {
        playSound("win", fileType: "wav")
        
        // TODO: Can refactor this for more abstraction
        var highScoreString = ""
        let score = computeScore(self.gameMode, numberOfSetsCompleted: numberOfSetsCompleted, timeCount: timeCount)
        if isHighScore(self.gameMode, score: score) {
            saveNewHighScore(self.gameMode, score: score)
            highScoreString = " Highscore!"
        }
        
        // TODO: Refactor this into helper function
        let alertView = SCLAlertView()
        alertView.showCloseButton = false
        alertView.addButton("Main Menu", target:self, selector:Selector("goToMainMenu"))
        alertView.addButton("Let me play one more!", target:self, selector:Selector("resetRound"))
        
        switch self.gameMode {
        case .TimerSet1, .TimerSet3, .TimerSet5:
            alertView.showSuccess("\(score) pts\(highScoreString)", subTitle: "You completed \(numberOfSetsCompleted) sets in \(timerModeCountSec) sec")
        default: alertView.showSuccess("\(score) pts\(highScoreString)", subTitle: "You completed \(numberOfSetsCompleted) sets in \(timeCount) sec")

        }
        
        // Timecount set to 0
        timeCount = stopTimer()
    }
    
    func resetRound() {
        startGame()
    }
    
    func goToMainMenu() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func initializecardViewsFromButtonsInView() {
        for view in self.view.subviews as [UIView] {
            if let btn = view as? UIButton {
                if (btn.tag > 0) {
                    cardViews[btn.tag] = btn;
                    cardViews[btn.tag]!.layer.cornerRadius = 10
                    cardViews[btn.tag]!.clipsToBounds = true
                    // We're sure we have a button since we checked above
                    cardViews[btn.tag]!.setImage(UIImage(named: brain.titleOfButton(btn.tag)), forState: .Normal)
                    cardViews[btn.tag]!.setTitle("", forState: .Normal)
                    cardViews[btn.tag]!.updateButtonState(.UnSelected)
                }
            }
        }
    }

    private func unSelectCardsWithIds(ids: [Int]) {
        for id in ids {
            cardViews[id]!.updateButtonState(.UnSelected) // view update
            brain.unSelectCardWithId(id) // modal update
        }
    }
    
     // MARK: Timer functions
    
    func initializeTimerCoutValue() {
        self.timeCount = 0
        
        if self.gameMode == GameMode.TimerSet1 {
            self.timerModeCountSec = 60
            self.timeCount = self.timerModeCountSec
        } else if self.gameMode == GameMode.TimerSet3 {
            self.timerModeCountSec = 180
            self.timeCount = self.timerModeCountSec
        } else if self.gameMode == GameMode.TimerSet5 {
            self.timerModeCountSec = 300
            self.timeCount = self.timerModeCountSec
        }
    }
    
    func resumeTimer() {
        timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("counter"), userInfo: nil, repeats: true)
    }
    
    func counter() {
        switch self.gameMode {
        case .TimerSet1, .TimerSet3, .TimerSet5:
            --timeCount
            if timeCount == 0 {
                self.roundCompleteAlert()
            }
        default: ++timeCount
        }
    }
    
    func pauseTimer() {
        timer.invalidate()
    }
    
    func resetTimer() -> Int {
        timer.invalidate()
        return 0
    }
    
    func stopTimer() -> Int {
        timer.invalidate()
        return 0
    }
    
    // MARK: Sound funcs
    
    func playSound(fileName: String, fileType: String) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        
        if userDefaults.boolForKey("SoundSettingEnabled") {
            if !userDefaults.boolForKey("SoundEnabled") {
                return
            }
        }
    
        let alertSound = NSURL(fileURLWithPath: NSBundle.mainBundle().pathForResource(fileName, ofType: fileType)!)
        
        do {
            // Removed deprecated use of AVAudioSessionDelegate protocol
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategorySoloAmbient)
            try AVAudioSession.sharedInstance().setActive(true)
            audioPlayer = try AVAudioPlayer(contentsOfURL: alertSound)
            audioPlayer.prepareToPlay()
            audioPlayer.play()
        } catch _ {
           print("Could not play sound file \(alertSound)")
        }
    }
    
    func computeScore(gameMode: GameMode, numberOfSetsCompleted: Int, timeCount: Int) -> Int {
        
        var score = 0
        var scoreWithoutHint = 0
        
        switch gameMode {
        case .ClassicSet27, .ClassicSet54, .ClassicSet81:
            scoreWithoutHint = numberOfSetsCompleted * 1000000 / timeCount
            print("Score computed with \(numberOfSetsCompleted) sets completed, \(totalNumberOfHintsUsed) hints, in \(timeCount) sec")
        case .EasySet:
            scoreWithoutHint = numberOfSetsCompleted * 100000 / timeCount
            print("Score computed with \(numberOfSetsCompleted) sets completed, \(totalNumberOfHintsUsed) hints, in \(timeCount) sec")
        case .TimerSet1, .TimerSet3, .TimerSet5:
            scoreWithoutHint = numberOfSetsCompleted * 1000000 / timerModeCountSec
            print("Score computed with \(numberOfSetsCompleted) sets completed, \(totalNumberOfHintsUsed) hints, in \(timerModeCountSec) sec")
        }
        
        if numberOfSetsCompleted > 0 {
            score = scoreWithoutHint * (numberOfSetsCompleted * 3 - totalNumberOfHintsUsed) / (numberOfSetsCompleted * 3)
        } else {
            score = 0
        }
        
        return roundToTens(Double(score))
    }
    
    private func roundToTens(x : Double) -> Int {
        return 10 * Int(round(x / 10.0))
    }
    
    func isHighScore(gameMode: GameMode, score: Int) -> Bool{
        let userDefaults = NSUserDefaults.standardUserDefaults()
        return score > userDefaults.integerForKey(getKeyForGameMode(gameMode))
    }
    
    func saveNewHighScore(gameMode: GameMode, score: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let previousHighScore = userDefaults.integerForKey(getKeyForGameMode(gameMode))
        let newHighScore = max(score, previousHighScore)
        userDefaults.setInteger(newHighScore, forKey: getKeyForGameMode(gameMode))
    }
    
    func getKeyForGameMode(gameMode: GameMode) -> String{
        switch (gameMode) {
        case .ClassicSet27, .ClassicSet54, .ClassicSet81: return HighScoreKeys.HighScoreClassicSet
        case .TimerSet1, .TimerSet3, .TimerSet5: return HighScoreKeys.HighScoreTimerSet
        case .EasySet: return HighScoreKeys.HighScoreEasySet
        }
    }
}
