//
//  Telemetry
//
//  Created by Daniel Jilg on 27.11.19.
//  Copyright © 2019 breakthesystem. All rights reserved.
//

import Foundation
import CommonCrypto

enum TelemetryManagerConfiguation {
    static let telemetryAppID: String = "5AF9FDB3-6712-4C73-B367-958F367CC154"
    static let telemetryBaseURL: URL = URL(string: "http://127.0.0.1:8080")!
}

enum TelemetrySignalType: String {
    case appLaunchedRegularly
    case telemetryAppCreated
    case telemetryAppUpdated
    case telemetryAppDeleted
    case telemetryAppUsersShown
    case telemetryAppInsightsShown
    case telemetryAppSignalsShown
    case telemetryAppSettingsShown
    case userSettingsShown
    case organizationSettingsShown
}

final class TelemetryManager {
    private struct SignalPostBody: Codable {
        let type: String
        let clientUser: String
        let payload: Dictionary<String, String>?
    }

    func send(_ signalType: TelemetrySignalType, for clientUser: String, with additionalPayload: [String: String] = [:]) {
        // Do not send telemetry from simulator
        guard !isSimulator else { return }

        DispatchQueue.main.async { [self] in
            let path = "/api/v1/\(TelemetryManagerConfiguation.telemetryAppID)/signals/"
            let url = TelemetryManagerConfiguation.telemetryBaseURL.appendingPathComponent(path)

            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let payLoad: [String: String] = [
                "systemVersion": systemVersion,
                "appVersion": appVersion,
                "buildNumber": buildNumber,
                "isSimulator": "\(isSimulator)",
                "isTestFlight": "\(isTestFlight)",
                "isAppStore": "\(isAppStore)"
            ].merging(additionalPayload, uniquingKeysWith: { (_, last) in last })
            
            let signalPostBody: SignalPostBody = SignalPostBody(type: "\(signalType)", clientUser: sha256(str: clientUser), payload: payLoad)

            urlRequest.httpBody = try! JSONEncoder().encode(signalPostBody)

            let task = URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
                if let error = error { print(error, data as Any, response as Any) }
            }
            task.resume()
        }
    }
}

extension TelemetryManager {
    var isSimulatorOrTestFlight: Bool {
        return (isSimulator || isTestFlight)
    }

    var isSimulator: Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
            return false
        }
        return (path.contains("CoreSimulator") || path.contains("XCTestDevices"))
    }

    var isTestFlight: Bool {
        guard let path = Bundle.main.appStoreReceiptURL?.path else {
            return false
        }
        return path.contains("sandboxReceipt")
    }

    var isAppStore: Bool {
        return !isSimulatorOrTestFlight
    }
    
    var systemVersion: String {
        #if os(macOS)
        return "macOS \(ProcessInfo.processInfo.operatingSystemVersion)"
        #elseif os(iOS)
        return "iOS  \(UIDevice.current.systemVersion)"
        #elseif os(watchOS)
        return "watchOS \(UIDevice.current.systemVersion)"
        #elseif os(tvOS)
        return "tvOS \(UIDevice.current.systemVersion)"
        #else
        return "Unknown system version"
        #endif
    }

    var appVersion: String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion ?? "0"
    }

    var buildNumber: String {
        let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
        return buildNumber ?? "0"
    }
}

extension TelemetryManager {
    /**
     * Example SHA 256 Hash using CommonCrypto
     * CC_SHA256 API exposed from from CommonCrypto-60118.50.1:
     * https://opensource.apple.com/source/CommonCrypto/CommonCrypto-60118.50.1/include/CommonDigest.h.auto.html
     **/
    func sha256(str: String) -> String {
     
        if let strData = str.data(using: String.Encoding.utf8) {
            /// #define CC_SHA256_DIGEST_LENGTH     32
            /// Creates an array of unsigned 8 bit integers that contains 32 zeros
            var digest = [UInt8](repeating: 0, count:Int(CC_SHA256_DIGEST_LENGTH))
     
            /// CC_SHA256 performs digest calculation and places the result in the caller-supplied buffer for digest (md)
            /// Takes the strData referenced value (const unsigned char *d) and hashes it into a reference to the digest parameter.
            _ = strData.withUnsafeBytes {
                // CommonCrypto
                // extern unsigned char *CC_SHA256(const void *data, CC_LONG len, unsigned char *md)  -|
                // OpenSSL                                                                             |
                // unsigned char *SHA256(const unsigned char *d, size_t n, unsigned char *md)        <-|
                CC_SHA256($0.baseAddress, UInt32(strData.count), &digest)
            }
     
            var sha256String = ""
            /// Unpack each byte in the digest array and add them to the sha256String
            for byte in digest {
                sha256String += String(format:"%02x", UInt8(byte))
            }

            return sha256String
        }
        return ""
    }
}
