import Flutter
import UIKit
import Darwin
import FirebaseCore

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      FirebaseApp.configure()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    let channel = FlutterMethodChannel(
      name: "solufine/network_traffic",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      guard call.method == "readBytes" else {
        result(FlutterMethodNotImplemented)
        return
      }
      var addresses: UnsafeMutablePointer<ifaddrs>?
      guard getifaddrs(&addresses) == 0, let first = addresses else {
        result(nil)
        return
      }
      defer { freeifaddrs(first) }
      var total: UInt64 = 0
      var found = false
      var cursor: UnsafeMutablePointer<ifaddrs>? = first
      while let pointer = cursor {
        let interface = pointer.pointee
        defer { cursor = interface.ifa_next }
        let name = String(cString: interface.ifa_name)
        // Physical interfaces only: avoid counting VPN traffic twice.
        guard name.hasPrefix("en") || name.hasPrefix("pdp_ip"),
              interface.ifa_addr?.pointee.sa_family == UInt8(AF_LINK),
              let data = interface.ifa_data else { continue }
        let counters = data.assumingMemoryBound(to: if_data.self).pointee
        total += UInt64(counters.ifi_ibytes) + UInt64(counters.ifi_obytes)
        found = true
      }
      result(found ? NSNumber(value: total) : nil)
    }
  }
}
