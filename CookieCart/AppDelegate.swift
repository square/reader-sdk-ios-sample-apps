//
//  Copyright © 2018 Square, Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import UIKit
import SquareReaderSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Initialize Square Reader SDK
        SQRDReaderSDK.initialize(applicationLaunchOptions: launchOptions)
        
        // Create a window and show it
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.backgroundColor = #colorLiteral(red: 0.4705882353, green: 0.8, blue: 0.7725490196, alpha: 1)
        window.makeKeyAndVisible()
        window.rootViewController = AppViewController()
        self.window = window
        
        return true
    }
}
