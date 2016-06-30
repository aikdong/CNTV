//
//  AppDelegate.swift
//  SampleRecipe
//
//  Created by toshi0383 on 12/28/15.
//  Copyright © 2015 toshi0383. All rights reserved.
//

import UIKit
import TVMLKitchen
import JavaScriptCore
import Prephirences
import SwiftyJSON
import Alamofire
import M3U8Kit2

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var tabbar: KitchenTabBar?
    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        _ = prepareMyKitchen(launchOptions)
        
        loadData();
        
        return true
    }
    
    func loadData() {
        if let tabbar = self.tabbar {
            Kitchen.reloadTab(atIndex: 0, recipe: tabbar)
        } else{
            self.tabbar = KitchenTabBar(items:[CatalogTab(),SearchTab(),SettingsTab()])
            Kitchen.serve(recipe: self.tabbar!)
        }
    }
    
    func playJSON(json: JSON) {
        
        if json["ack"] == "yes" {
            
//            let videoType = ["flv","hls","hds"]
            let videoType = ["hls"]

            var urls = [NSURL]()
            
            for type in videoType {
                let item_url = json["\(type)_url"]
                for i in 1...5 {
                    let url = item_url["\(type)\(i)"].stringValue
                    if  !url.isEmpty {
                        print("\(type)\(i):\(url)")
                        urls.append(NSURL(string: url)!)
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                let pagePlayerController = PageAVPlayerController(urls: urls)
                Kitchen.navigationController.presentViewController(pagePlayerController, animated: true, completion:nil)
            }
            
        }else{
            let button = AlertButton(title: "OK",actionID: "Alert_OK")
            let alert = AlertRecipe(title: "Can not play", description:  "Can not play this channel", buttons: [button], presentationType: .Modal)
            Kitchen.serve(recipe: alert)
            
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        if let viewController = Kitchen.window.rootViewController as? AVPlayerController{
            viewController.pause()
        }
        
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if let viewController = Kitchen.window.rootViewController as? AVPlayerController{
            viewController.play()
        }
    }
    
    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        if let viewController = Kitchen.window.rootViewController as? AVPlayerController{
            viewController.pause()
        }
    }
    
    private func prepareMyKitchen(launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let cookbook = Cookbook(launchOptions: launchOptions)
        cookbook.evaluateAppJavaScriptInContext = {appController, jsContext in
            /// set Exception handler
            /// called on JS error
            jsContext.exceptionHandler = {context, value in
                #if DEBUG
                    debugPrint(context)
                    debugPrint(value)
                #endif
                assertionFailure("You got JS error. Check your javascript code.")
            }
            
            // - SeeAlso: http://nshipster.com/javascriptcore/
            /// Inject native code block named 'debug'.
            let consoleLog: @convention(block) String -> Void = { message in
                print(message)
            }
            jsContext.setObject(unsafeBitCast(consoleLog, AnyObject.self),
                                forKeyedSubscript: "debug")
        }
        cookbook.onError = { error in
            let title = "Error Launching Application"
            let message = error.localizedDescription
            let alertController = UIAlertController(title: title, message: message, preferredStyle:.Alert )
            
            Kitchen.navigationController.presentViewController(alertController, animated: true) { }
        }
        cookbook.actionIDHandler = { actionID in
            let actionComponents = actionID.componentsSeparatedByString("_")
            let action = actionComponents[0]
            
            dispatch_async(dispatch_get_main_queue()) {
                if action == "Alert" {
                    Kitchen.dismissModal()
                    let todo = actionComponents[1]
                    switch todo {
                    case "loadData":
                        self.loadData()
                    default:
                        return
                    }
                }else if action == "Play" {
                    let channel = actionComponents[1]
                    Alamofire.request(.GET, "http://vdn.live.cntv.cn/api2/liveHtml5.do?client=html5&channel=pa://cctv_p2p_hd"+channel)
                        .validate()
                        .responseString { response in
                            switch response.result {
                            case .Success:
                                if let JSONString = response.result.value {
                                    let start = JSONString.rangeOfString("{")!
                                    let end = JSONString.rangeOfString("}", options: .BackwardsSearch)!

                                    if let dataFromString = JSONString.substringWithRange(start.startIndex ... end.startIndex).dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                                        let json = JSON(data: dataFromString)
                                        
                                        self.playJSON(json)
                                    }

                                }
                                
                            case .Failure(let error):
                                print(error)
                            }
                    }
                }
            }
        }
        cookbook.playActionIDHandler = {actionID in
            
        }
        cookbook.httpHeaders = [
            "Content-Type": "application/json"
        ]
        
        cookbook.responseObjectHandler = { response in
            /// Save cookies
            if let fields = response.allHeaderFields as? [String: String],
                let url = response.URL
            {
                let cookies = NSHTTPCookie.cookiesWithResponseHeaderFields(fields, forURL: url)
                for c in cookies {
                    NSHTTPCookieStorage.sharedCookieStorageForGroupContainerIdentifier(
                        "\(NSBundle.mainBundle().bundleIdentifier).samplerecipe").setCookie(c)
                }
            }
            return true
        }
        
        Kitchen.prepare(cookbook)
        
        return true
    }
    
    struct SearchTab: TabItem {
        let title = "Search"
        func handler() {
            let search = MySearchRecipe(type: .TabSearch)
            Kitchen.serve(recipe: search)
        }
    }
    
    struct SettingsTab: TabItem {
        let title = "Settings"
        func handler() {
            Kitchen.serve(xmlFile: "Settings.xml", type: .Tab)
        }
    }
    
    struct CatalogTab: TabItem {
        let title = "Catalog"
        func handler() {
            Kitchen.serve(recipe: catalog)
        }
        private var catalog: CatalogRecipe {

            let model: M3U8PlaylistModel?
            do {
                let channelString = try String(contentsOfFile: NSBundle.mainBundle().pathForResource("channels", ofType: "m3u8")!, encoding: NSUTF8StringEncoding);
                try model = M3U8PlaylistModel(string: channelString, baseURL: "http://vdn.live.cntv.cn/api2/liveHtml5.do?client=html5&channel=pa://cctv_p2p_hd")
            } catch {
                print(error)
                model = nil
            }
            
            var sections = [Section]()
            
            if let model = model {
                let (width, height) = (376, 250)
                
                var contents: Array<Section.ContentTuple> = []
                
                for i in 0..<model.mainMediaPl.segmentList.count {
                    
                    if let sinfo = model.mainMediaPl.segmentList.segmentInfoAtIndex(i){

                        let content = Section.ContentTuple(sinfo.title, sinfo.tvgLogo, "Play_"+sinfo.URI, nil, width, height)
                        
                        contents.append(content)
                    }
                }
                let section = Section(title: "Section", args: contents)
                sections.append(section)
            }
            
            var catalog = CatalogRecipe(banner: "Channels", sections: sections)
            catalog.presentationType = .Tab
            return catalog
        }
    }
}
