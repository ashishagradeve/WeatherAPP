import Foundation

/// A helper responsible for securely retrieving API keys from the app's configuration.
///
/// Add your OpenWeather API key to the app target's Info.plist with the key `OPENWEATHER_API_KEY`.
/// Prefer configuring this via build settings or an xcconfig so the key is not committed to source control.
enum APIKeyProvider {
    /// The Info.plist key under which the OpenWeather API key is stored.
    private static let openWeatherPlistKey = "OPENWEATHER_API_KEY"

    /// Returns the OpenWeather API key from Info.plist.
    /// - Note: In Debug builds, this will assert if the key is missing to help catch misconfiguration early.
    static func openWeatherAPIKey() -> String {
        let value = Bundle.main.object(forInfoDictionaryKey: openWeatherPlistKey) as? String
        let trimmed = value?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        #if DEBUG
        if trimmed.isEmpty {
            preconditionFailure("Missing OPENWEATHER_API_KEY in Info.plist. Add it to your target's Info and keep it out of source control (e.g., via xcconfig).")
        }
        #endif
        return trimmed
    }

    /// Convenience accessor for the OpenWeather API key.
    static var openWeather: String { openWeatherAPIKey() }
}
