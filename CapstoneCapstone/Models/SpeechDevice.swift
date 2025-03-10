//
//  SpeechService.swift
//  Google TTS Demo
//
//  Created by Alejandro Cotilla on 5/30/18.
//  Copyright © 2018 Alejandro Cotilla. All rights reserved.
//

import UIKit
import AVFoundation

enum VoiceType: String {
    case undefined
    case waveNetFemaleUK = "en-GB-Wavenet-F"
    case waveNetMaleUK = "en-GB-Wavenet-D"
    case studioMaleUK = "en-GB-Studio-B"
    case studioFemaleUK = "en-GB-Studio-C"
}

let ttsAPIUrl = "https://texttospeech.googleapis.com/v1beta1/text:synthesize"

class SpeechService: NSObject, AVAudioPlayerDelegate {

    static let shared = SpeechService()
    internal(set) var busy: Bool = false
    internal(set) var apiKeyMissing: Bool = false
    
    internal var player: AVAudioPlayer?
    private var completionHandler: (() -> Void)?
    
    func speak(text: String, voiceType: VoiceType = .studioFemaleUK, completion: @escaping () -> Void) {
        guard !self.busy else {
            print("Speech Service busy!")
            return
        }
        
        // Get API key from UserSettings
        let apiKey = UserSettingsManager.shared.currentSettings.ttsApiKey
        
        // Check if API key is empty
        guard !apiKey.isEmpty else {
            print("API Key is missing!")
            self.apiKeyMissing = true
            DispatchQueue.main.async {
                completion()
            }
            return
        }
        
        self.apiKeyMissing = false
        self.busy = true
        
        DispatchQueue.global(qos: .background).async {
            let postData = self.buildPostData(text: text, voiceType: voiceType)
            let headers = ["X-Goog-Api-Key": apiKey, "Content-Type": "application/json; charset=utf-8"]
            let response = self.makePOSTRequest(url: ttsAPIUrl, postData: postData, headers: headers)

            // Get the `audioContent` (as a base64 encoded string) from the response.
            guard let audioContent = response["audioContent"] as? String else {
                print("Invalid response: \(response)")
                self.busy = false
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            // Decode the base64 string into a Data object
            guard let audioData = Data(base64Encoded: audioContent) else {
                self.busy = false
                DispatchQueue.main.async {
                    completion()
                }
                return
            }
            
            DispatchQueue.main.async {
                self.completionHandler = completion
                self.player = try! AVAudioPlayer(data: audioData)
                self.player?.delegate = self
                self.player!.play()
            }
        }
    }
    
    private func buildPostData(text: String, voiceType: VoiceType) -> Data {
        
        var voiceParams: [String: Any] = [
            // All available voices here: https://cloud.google.com/text-to-speech/docs/voices
            "languageCode": "en-GB"
        ]
        
        if voiceType != .undefined {
            voiceParams["name"] = voiceType.rawValue
        }
        
        let params: [String: Any] = [
            "input": [
                "text": text
            ],
            "voice": voiceParams,
            "audioConfig": [
                // All available formats here: https://cloud.google.com/text-to-speech/docs/reference/rest/v1beta1/text/synthesize#audioencoding
                "audioEncoding": "LINEAR16"
            ]
        ]

        // Convert the Dictionary to Data
        let data = try! JSONSerialization.data(withJSONObject: params)
        return data
    }
    
    // Just a function that makes a POST request.
    private func makePOSTRequest(url: String, postData: Data, headers: [String: String] = [:]) -> [String: AnyObject] {
        var dict: [String: AnyObject] = [:]
        
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = postData

        for header in headers {
            request.addValue(header.value, forHTTPHeaderField: header.key)
        }
        
        // Using semaphore to make request synchronous
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] {
                dict = json
            }
            
            semaphore.signal()
        }
        
        task.resume()
        _ = semaphore.wait(timeout: DispatchTime.distantFuture)
        
        return dict
    }
    
    // Implement AVAudioPlayerDelegate "did finish" callback to cleanup and notify listener of completion.
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.player?.delegate = nil
        self.player = nil
        self.busy = false
        
        self.completionHandler!()
        self.completionHandler = nil
    }
}

@available(iOS 13.0, macOS 12.0, *)
class TTS {
    func textToSpeech(_ text: String, voiceType: VoiceType) {
        // Check if TTS is enabled in settings
        guard UserSettingsManager.shared.currentSettings.ttsEnabled else {
            return
        }
        
        SpeechService.shared.speak(text: text, voiceType: voiceType) {
            // If API key is missing, show the API key dialog
            if SpeechService.shared.apiKeyMissing {
                NotificationCenter.default.post(name: NSNotification.Name("ShowTTSAPIKeyDialog"), object: nil)
            }
        }
    }
    
    func stopSpeech() {
        // Stop any ongoing speech by setting busy to false and stopping the player
        if SpeechService.shared.busy {
            SpeechService.shared.player?.stop()
            SpeechService.shared.player = nil
            SpeechService.shared.busy = false
        }
    }
}

