import Flutter
import ActivityKit
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  private var liveActivityBridge: IxerciseLiveActivityBridge?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    UNUserNotificationCenter.current().delegate = self
    if let registrar = registrar(forPlugin: "IxerciseLiveActivityBridge") {
      liveActivityBridge = IxerciseLiveActivityBridge(binaryMessenger: registrar.messenger())
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}

final class IxerciseLiveActivityBridge {
  private let channel: FlutterMethodChannel

  init(binaryMessenger: FlutterBinaryMessenger) {
    channel = FlutterMethodChannel(
      name: "ixercise/live_activity",
      binaryMessenger: binaryMessenger
    )
    channel.setMethodCallHandler(handle)
  }

  private func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "isSupported":
      if #available(iOS 16.2, *) {
        result(ActivityAuthorizationInfo().areActivitiesEnabled)
      } else {
        result(false)
      }
    case "sync":
      guard let arguments = call.arguments as? [String: Any] else {
        result(FlutterError(code: "bad_args", message: "Expected snapshot map", details: nil))
        return
      }
      if #available(iOS 16.2, *) {
        Task {
          do {
            try await IxerciseLiveActivityManager.shared.sync(arguments)
            result(true)
          } catch {
            result(FlutterError(code: "sync_failed", message: error.localizedDescription, details: nil))
          }
        }
      } else {
        result(FlutterError(code: "unsupported", message: "ActivityKit requires iOS 16.2+", details: nil))
      }
    case "end":
      if #available(iOS 16.2, *) {
        Task {
          await IxerciseLiveActivityManager.shared.end()
          result(true)
        }
      } else {
        result(false)
      }
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}

@available(iOS 16.2, *)
final class IxerciseLiveActivityManager {
  static let shared = IxerciseLiveActivityManager()

  private var activeActivity: Activity<IxerciseWorkoutActivityAttributes>?

  private init() {}

  func sync(_ snapshot: [String: Any]) async throws {
    guard ActivityAuthorizationInfo().areActivitiesEnabled else {
      return
    }

    let attributes = IxerciseWorkoutActivityAttributes(
      sessionId: snapshot.stringValue("sessionId"),
      planName: snapshot.stringValue("planName")
    )
    let state = IxerciseWorkoutActivityAttributes.ContentState(
      phase: snapshot.stringValue("phase"),
      title: snapshot.stringValue("title"),
      subtitle: snapshot.stringValue("subtitle"),
      remainingSeconds: snapshot.optionalIntValue("remainingSeconds"),
      totalSeconds: snapshot.optionalIntValue("totalSeconds"),
      progress: snapshot.doubleValue("progress"),
      isPaused: snapshot.boolValue("isPaused"),
      updatedAt: snapshot.dateValue("updatedAt")
    )

    if let activity = activeActivity {
      await activity.update(ActivityContent(state: state, staleDate: nil))
      return
    }

    activeActivity = try Activity<IxerciseWorkoutActivityAttributes>.request(
      attributes: attributes,
      content: ActivityContent(state: state, staleDate: nil),
      pushType: nil
    )
  }

  func end() async {
    guard let activity = activeActivity else {
      return
    }

    let finalState = activity.content.state
    await activity.end(
      ActivityContent(state: finalState, staleDate: nil),
      dismissalPolicy: .immediate
    )
    activeActivity = nil
  }
}

private extension Dictionary where Key == String, Value == Any {
  func stringValue(_ key: String) -> String {
    self[key] as? String ?? ""
  }

  func optionalIntValue(_ key: String) -> Int? {
    self[key] as? Int
  }

  func doubleValue(_ key: String) -> Double {
    self[key] as? Double ?? 0
  }

  func boolValue(_ key: String) -> Bool {
    self[key] as? Bool ?? false
  }

  func dateValue(_ key: String) -> Date {
    guard let milliseconds = self[key] as? Int else {
      return Date()
    }
    return Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
  }
}
