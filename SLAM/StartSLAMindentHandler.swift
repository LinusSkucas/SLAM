//
//  StartSLAMindentHandler.swift
//  SLAM
//
//  Created by Linus Skucas on 11/26/21.
//

import Foundation
import Intents

class StartSLAMIntentHandler: NSObject, StartSLAMIntentHandling {
    func handle(intent: StartSLAMIntent, completion: @escaping (StartSLAMIntentResponse) -> Void) {
        NotificationCenter.default.post(name: .toggleMic, object: nil)
        NSLog("hiii")
        let response = StartSLAMIntentResponse.init(code: .inProgress, userActivity: nil)
        completion(response)
    }
}
