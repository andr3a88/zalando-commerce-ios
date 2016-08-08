//
//  Copyright © 2016 Zalando SE. All rights reserved.
//

import Foundation

public struct Options {

    var useSandboxEnvironment: Bool
    var clientId: String
    var salesChannel: String
    var interfaceLanguage: String
    var configurationURL: NSURL

    @available( *, deprecated, message = "To be removed with AtlasSDK")
    init() {
        self.init(clientId: "", salesChannel: "")
    }

    public init(clientId: String, salesChannel: String, useSandbox: Bool = false,
        interfaceLanguage: String = "de_DE", configurationURL: NSURL? = nil) {
            self.clientId = clientId
            self.salesChannel = salesChannel
            self.useSandboxEnvironment = useSandbox
            self.interfaceLanguage = interfaceLanguage
            if let url = configurationURL {
                self.configurationURL = url
            } else {
                self.configurationURL = Options.defaultConfigurationURL(clientId: self.clientId, useSandbox: self.useSandboxEnvironment)
            }
    }

    public func validate() throws {
        if self.clientId.isEmpty {
            throw AtlasConfigurationError(status: .InitFailed, message: "Missing client ID")
        }
        if self.salesChannel.isEmpty {
            throw AtlasConfigurationError(status: .InitFailed, message: "Missing sales channel")
        }
        if self.interfaceLanguage.isEmpty {
            throw AtlasConfigurationError(status: .InitFailed, message: "Missing interface language")
        }
    }

}

extension Options: CustomStringConvertible {

    public var description: String {
        func formatOptional(text: String?, defaultText: String = "<NONE>") -> String {
            guard let text = text else { return defaultText }
            return "'\(text)'"
        }

        return "\(self.dynamicType) { "
            + "\n\tclientId = \(formatOptional(clientId))"
            + ",\n\tuseSandboxEnvironment = \(useSandboxEnvironment)"
            + ",\n\tsalesChannel = \(formatOptional(salesChannel))"
            + ",\n\tinterfaceLanguage = \(interfaceLanguage)"
            + " }"
    }

}

extension Options {

    enum Environment: String {
        case staging = "staging"
        case production = "production"
    }

    enum ResponseFormat: String {
        case json = "json"
        case yaml = "yaml"
        case properties = "properties"
    }

    private static func defaultConfigurationURL(clientId clientId: String, useSandbox: Bool,
        inFormat format: ResponseFormat = .json) -> NSURL {
            let urlComponents = NSURLComponents(validUrlString: "https://atlas-config-api.dc.zalan.do/api/config/")
            let basePath = (urlComponents.path ?? "/")

            let environment: Environment = useSandbox ? .staging : .production
            urlComponents.path = "\(basePath)\(clientId)-\(environment).\(format)"
            return urlComponents.validURL
    }

}
