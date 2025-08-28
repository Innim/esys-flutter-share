import Flutter
import UIKit

public class SwiftEsysFlutterSharePlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "channel:github.com/orgs/esysberlin/esys-flutter-share", binaryMessenger: registrar.messenger())
        let instance = SwiftEsysFlutterSharePlugin()
        
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if(call.method == "text"){
            self.text(arguments: call.arguments) { success in
                result(success)
            }
        }
        if(call.method == "file"){
            self.file(arguments: call.arguments) { success in
                result(success)
            }
        }
        if(call.method == "files"){
            self.files(arguments: call.arguments) { success in
                result(success)
            }
        }
    }
    
    func text(arguments:Any?, completion: @escaping (Bool) -> Void) {
        // prepare method channel args
        // no use in ios
        //// let title:String = argsMap.value(forKey: "title") as! String
        let argsMap = arguments as! NSDictionary
        let text:String = argsMap.value(forKey: "text") as! String

        // set up activity view controller
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)

        // present the view controller
        let controller = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController
        activityViewController.popoverPresentationController?.sourceView = controller.view
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            completion(completed)
        }
        controller.show(activityViewController, sender: self)
    }
    
    func file(arguments:Any?, completion: @escaping (Bool) -> Void) {
        let argsMap = arguments as! NSDictionary
        let text:String = argsMap.value(forKey: "text") as! String
        let filePath:String = argsMap.value(forKey: "filePath") as! String
        
        let fileURL = URL(fileURLWithPath: filePath)
        
        // prepare activity items
        var activityItems:[Any] = [fileURL];
        if(!text.isEmpty){
            // add optional text
            activityItems.append(text);
        }
        // set up activity view controller
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        // present the view controller
        let controller = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController
        activityViewController.popoverPresentationController?.sourceView = controller.view
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            completion(completed)
        }
        controller.show(activityViewController, sender: self)
    }
    
    func files(arguments:Any?, completion: @escaping (Bool) -> Void) {
        let argsMap = arguments as! NSDictionary
        let text:String = argsMap.value(forKey: "text") as! String
        let filePaths:[String] = argsMap.value(forKey: "filePaths") as! [String]

        // prepare file URLs and activity items
        var fileURLs: [URL] = []
        var activityItems:[Any] = []
        for filePath in filePaths {
        let url = URL(fileURLWithPath: filePath)
            fileURLs.append(url)
            activityItems.append(url);
        }
        
        if(!text.isEmpty){
            // add optional text
            activityItems.append(text);
        }

        // set up activity view controller
        let activityViewController:UIActivityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)

        // present the view controller
        let controller = UIApplication.shared.keyWindow!.rootViewController as! FlutterViewController
        activityViewController.popoverPresentationController?.sourceView = controller.view
        activityViewController.completionWithItemsHandler = { activityType, completed, returnedItems, error in
            completion(completed)
        }
        controller.show(activityViewController, sender: self)
    }

}
