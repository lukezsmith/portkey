// Environment.swift

import Foundation

public enum Env {
  // MARK: - Keys
  enum Keys {
    enum Plist {
      static let awsRegion = "AWS_REGION"
      static let awsSecretAccessKey = "AWS_SECRET_ACCESS_KEY"
        static let awsAccessKeyId = "AWS_ACCESS_KEY_ID"
    }
  }

  // MARK: - Plist
  private static let infoDictionary: [String: Any] = {
    guard let dict = Bundle.main.infoDictionary else {
      fatalError("Plist file not found")
    }
    return dict
  }()
  static let awsRegion: String = {
      guard let awsRegion = Env.infoDictionary[Keys.Plist.awsRegion] as? String else {
      fatalError("AWS_REGION not set in plist for this environment")
    }
    return awsRegion
  }()

    static let awsSecretAccessKey: String = {
      guard let awsSecretAccessKey = Env.infoDictionary[Keys.Plist.awsSecretAccessKey] as? String else {
        fatalError("AWS_SECRET_ACCESS_KEY not set in plist for this environment")
      }
      return awsSecretAccessKey
    }()
    
    static let awsAccessKeyId: String = {
      guard let awsAccessKeyId = Env.infoDictionary[Keys.Plist.awsAccessKeyId] as? String else {
        fatalError("AWS_ACCESS_KEY_ID not set in plist for this environment")
      }
      return awsAccessKeyId
    }()
}
