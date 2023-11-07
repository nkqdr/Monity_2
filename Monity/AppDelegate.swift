//
//  AppDelegate.swift
//  Monity
//
//  Created by Niklas Kuder on 07.11.23.
//

#if os(iOS)
class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    func application(
      _ application: UIApplication,
      configurationForConnecting connectingSceneSession: UISceneSession,
      options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
      let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
      sceneConfig.delegateClass = SceneDelegate.self
      return sceneConfig
    }
}
#endif

#if canImport(UIKit)
import Foundation
import UIKit
/// PassThroughWindow
public class PassThroughWindow: UIWindow {
    
    /// hitTest - override function
    /// - Parameters:
    ///   - point: a CGPoint locating the hit event
    ///   - event: UIEvent
    /// - Returns: view of the root view controller or nil
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == hitView ? nil : hitView
  }
}



#endif


#if os(iOS)
import Foundation
import SwiftUI


class SceneDelegate: UIResponder, UIWindowSceneDelegate, ObservableObject {
    var blurWindow: UIWindow?
    weak var windowScene: UIWindowScene?

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
      windowScene = scene as? UIWindowScene
      setupPrivacyBlurWindow()
  }

// without a second app window, the blur view will not appear above a sheet, fullScreenCover etc.
// special thanks to Federico Zanetello (www.fivestars.blog) for this function
    func setupPrivacyBlurWindow() {
        guard let windowScene = windowScene else {
            return
          }

      let blurViewController = UIHostingController(rootView: PrivacyBlurView())
        blurViewController.view.backgroundColor = .clear

      let blurWindow = PassThroughWindow(windowScene: windowScene)
        blurWindow.rootViewController = blurViewController
        blurWindow.isHidden = true
      self.blurWindow = blurWindow
    }
    
    func hide() {
        UIView.animate(withDuration: 0.3, animations: {
            self.blurWindow?.alpha = 0.0
        }) { _ in
            self.blurWindow?.isHidden = true
        }
    }
    
    func show() {
        self.blurWindow?.isHidden = false
        UIView.animate(withDuration: 0.3, animations: {
            self.blurWindow?.alpha = 1.0
        })
    }
}
#endif
