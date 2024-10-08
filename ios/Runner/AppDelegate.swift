import UIKit
import Flutter
import Firebase
import GoogleMaps
import FirebaseCore

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    
  ) -> Bool {
    FirebaseApp.configure() 
    GMSServices.provideAPIKey("AIzaSyAjUlN3JEYBtNNkqnGglmzH86u_a56Skec")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
