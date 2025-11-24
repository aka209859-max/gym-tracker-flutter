import Flutter
import UIKit
import GoogleMaps  // ← 追加: Google Maps機能の読み込み

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // ↓↓ 追加: Google MapsにAPIキーを渡す（これが一番重要！）
    GMSServices.provideAPIKey("AIzaSyA9XmQSHA1llGg7gihqjmOOIaLA856fkLc") 
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
