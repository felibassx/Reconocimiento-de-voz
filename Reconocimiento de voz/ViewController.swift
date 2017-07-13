//
//  ViewController.swift
//  Reconocimiento de voz
//
//  Created by Felipe Hernandez on 11-07-17.
//  Copyright © 2017 kafecode. All rights reserved.
//

import UIKit
import Speech

class ViewController: UIViewController, AVAudioRecorderDelegate {

    @IBOutlet var textView: UITextView!
    
    //creo una vartiable para la sesión del audio
    var audioRecordingSession : AVAudioSession!
    
    //Objeto de grabacion
    var audioRecorder : AVAudioRecorder!
    
    //constante con el nombre del archi a grabar
    let audioFileName = "audio-recordered.m4a"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        recordingAudioSetup()
        //recognizeSpeech()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func recognizeSpeech(){
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            
            if authStatus == SFSpeechRecognizerAuthorizationStatus.authorized{
                
                //ruta para llegar al audio
                //if let urlPath = Bundle.main.url(forResource: "audio-recordered", withExtension: "m4a"){
                
                let recognizer = SFSpeechRecognizer()
                let request = SFSpeechURLRecognitionRequest(url: self.directoryURL()!)
                
                recognizer?.recognitionTask(with: request, resultHandler: { (result, error) in
                    
                    if let error = error{
                        print("Error: \(error.localizedDescription)")
                    }else{
                        
                        self.textView.text = result?.bestTranscription.formattedString
                        
                    }
                    
                    
                })
                
                //}
            }else{
                print("No tengo permisos para acceder al speech framework")
            }
            
        }
        
    }
    
    func recordingAudioSetup(){
        //inicializo la variable
        audioRecordingSession = AVAudioSession.sharedInstance()
        
        do{
        
            try audioRecordingSession.setCategory(AVAudioSessionCategoryRecord)
            try audioRecordingSession.setActive(true)
            
            //permisos para grabar un audio
            audioRecordingSession.requestRecordPermission({[unowned self] (allowed: Bool) in
                if allowed {
                    //comenzar a grabar
                    self.startRecordering()
                }else{
                    print("Se necesitan permisos para grabar")
                }
            })
        
        }
        catch{
            print("Se ha producido un error al configurar audioRecordingSession")
        }
    
    }
    
    func directoryURL() -> URL?{
        
        let fileManager = FileManager.default
        let urls = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = urls[0] as URL
      
        return documentDirectory.appendingPathComponent(audioFileName) as URL
        
    }
    
    func startRecordering(){
        
        //parametros
        let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                        AVSampleRateKey: 12000.0,
                        AVNumberOfChannelsKey: 1 as NSNumber,
                        AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
        
        do {
            
            audioRecorder = try AVAudioRecorder(url: directoryURL()!, settings: settings)
            audioRecorder.delegate = self
            audioRecorder.record()
            
            Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.stopRecording), userInfo: nil, repeats: false)
            
        } catch {
            print("No se ha podido grabar el audio.")
        }
    
    }
    
    func stopRecording(){
        audioRecorder.stop()
        audioRecorder = nil
        
        Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(self.recognizeSpeech), userInfo: nil, repeats: false)
    
    }


}

