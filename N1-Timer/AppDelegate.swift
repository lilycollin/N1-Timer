import UIKit
import AppsFlyerLib
import FBSDKCoreKit
import UserNotifications
import AppTrackingTransparency
import AdSupport

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    //DEVELOPER MODE
    let appsFlyerDevKey = "iRXcZxgE5u2FPVN8GqqWKc"
    let appleAppId = "6469603910"
    
    var window: UIWindow?
    
    let localeLocalizationCode = NSLocale.current.languageCode
    
    var currentTimeZone: String {
        return TimeZone.current.identifier
    }
    
    var localizationTimeZoneAbbrtion: String {
        return TimeZone.current.abbreviation() ?? ""
    }
    
    var oldAndNotWorkingNames: [String : Any] = [:]
    var dataAttribution: [String : Any] = [:]

    var facebookDeepLink = ""
    var deep_link_sub1 = ""
    var deep_link_sub2 = ""
    var deep_link_sub3 = ""
    var deep_link_sub4 = ""
    var deep_link_sub5 = ""
    var deepLinkStr = ""
    var token = ""
    var idfa = ""
    var id =  ""
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        if #available(iOS 13.0, *) {
                          window?.overrideUserInterfaceStyle = .dark
                      }
        
        faceSDK()
        
        AppsFlyerLib.shared().appsFlyerDevKey = appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID = appleAppId
        AppsFlyerLib.shared().isDebug = true
        AppsFlyerLib.shared().deepLinkDelegate = self
        AppsFlyerLib.shared().delegate = self
        id = AppsFlyerLib.shared().getAppsFlyerUID()
        
        UNUserNotificationCenter.current().delegate  = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge], completionHandler: {
            success, error in
            guard success else {
                return
            }
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        })
        
        ApplicationDelegate.shared.application(
            application,
            didFinishLaunchingWithOptions: launchOptions
        )
        
        return true
    }
    
    func faceSDK() {
            AppLinkUtility.fetchDeferredAppLink { (url, error) in
                if let error = error {
                    print("Received error while fetching deferred app link %@", error)
                }
                if let url = url {
                    self.facebookDeepLink = url.absoluteString
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    
                }
            }
        }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        if #available(iOS 14, *) {
            AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
            ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                switch status {
                case .denied:
                    self.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    print("AuthorizationSatus is denied")
                case .notDetermined:
                    print("AuthorizationSatus is notDetermined")
                case .restricted:
                    print("AuthorizationSatus is restricted")
                case .authorized:
                    self.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                    print("AuthorizationSatus is authorized")
                @unknown default:
                    fatalError("Invalid authorization status")
                }
                DispatchQueue.main.async {
                                (self.window?.rootViewController as? LoadingViewController)?.sendToRequest()
                            }
            })
        } else {
            self.idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
        }
        AppsFlyerLib.shared().start()
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        AppsFlyerLib.shared().continue(userActivity, restorationHandler: nil)
        return true
    }
    
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
        ApplicationDelegate.shared.application(
            app,
            open: url,
            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        AppsFlyerLib.shared().handlePushNotification(userInfo)
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        token = tokenParts.joined()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        self.token = "Error"
        print("\(error.localizedDescription)")
    }
}

extension AppDelegate: DeepLinkDelegate {
    func didResolveDeepLink(_ result: DeepLinkResult) {
        switch result.status {
        case .notFound:
            NSLog("[AFSDK] Deep link not found")
            return
        case .failure:
            print("Error %@", result.error!)
            return
        case .found:
            NSLog("[AFSDK] Deep link found")
        }

        guard let deepLinkObj: DeepLink = result.deepLink else {
            NSLog("[AFSDK] Could not extract deep link object")
            return
        }

        let subLinkKeys = ["deep_link_sub1", "deep_link_sub2", "deep_link_sub3", "deep_link_sub4", "deep_link_sub5"]
        for key in subLinkKeys {
            if deepLinkObj.clickEvent.keys.contains(key), let referrerId = deepLinkObj.clickEvent[key] as? String {
                NSLog("[AFSDK] AppsFlyer: Referrer ID: \(referrerId)")
                switch key {
                case "deep_link_sub1":
                    self.deep_link_sub1 = referrerId
                case "deep_link_sub2":
                    self.deep_link_sub2 = referrerId
                case "deep_link_sub3":
                    self.deep_link_sub3 = referrerId
                case "deep_link_sub4":
                    self.deep_link_sub4 = referrerId
                case "deep_link_sub5":
                    self.deep_link_sub5 = referrerId
                default:
                    break
                }
            } else {
                NSLog("[AFSDK] Could not extract referrerId")
            }
        }

        let deepLinkStr: String = deepLinkObj.toString()
        NSLog("[AFSDK] DeepLink data is: \(deepLinkStr)")
        self.deepLinkStr = deepLinkStr

        if deepLinkObj.isDeferred {
            NSLog("[AFSDK] This is a deferred deep link")
        } else {
            NSLog("[AFSDK] This is a direct deep link")
        }
    }
}

extension Data {
    var hexString: String {
        let hexString = map { String(format: "%02.2hhx", $0) }.joined()
        return hexString
    }
}

extension AppDelegate: AppsFlyerLibDelegate{
    func onConversionDataSuccess(_ installData: [AnyHashable: Any]) {
        oldAndNotWorkingNames = installData as! [String : Any]
        for (key, value) in installData {
            print(key, ":", value)
        }
        if let status = installData["af_status"] as? String {
            if (status == "Non-organic") {
                if let sourceID = installData["media_source"],
                   let campaign = installData["campaign"] {
                    print("////////////////////////////////////////////////////////This is a Non-Organic install. Media source: \(sourceID)  Campaign: \(campaign)////////////////////////////////////////////////////////")
                }
            } else {
                print("This is an organic install.")
            }
            if let is_first_launch = installData["is_first_launch"] as? Bool,
               is_first_launch {
                print("First Launch")
            } else {
                print("Not First Launch")
            }
        }
    }
    func onConversionDataFail(_ error: Error) {
        print(error)
    }
    func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        self.dataAttribution = attributionData as! [String : Any]
        print("onAppOpenAttribution data:")
        for (key, value) in attributionData {
            print(key, ":",value)
        }
    }
    func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
    }
}
