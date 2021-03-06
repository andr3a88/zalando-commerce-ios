//
//  Copyright © 2016-2017 Zalando SE. All rights reserved.
//

import XCTest
import Foundation
import Nimble

@testable import ZalandoCommerceAPI

class OptionsTests: XCTestCase {

    let clientId = "CLIENT_ID_SPEC"
    let salesChannel = "SALES_CHANNEL_SPEC"
    let interfaceLanguage = "fr"
    let useSandbox = true
    let emptyBundle = Bundle()
    let testsBundle = Bundle(for: OptionsTests.self)

    func testInitialization() {
        let opts = Options(clientId: clientId,
                           salesChannel: salesChannel,
                           useSandboxEnvironment: useSandbox,
                           interfaceLanguage: interfaceLanguage)

        expect(opts.clientId) == clientId
        expect(opts.salesChannel) == salesChannel
        expect(opts.interfaceLanguage) == interfaceLanguage
        expect(opts.useSandboxEnvironment) == useSandbox
    }

    func testNoDefaultLanguage() {
        let opts = Options(infoBundle: emptyBundle)
        expect(opts.interfaceLanguage).to(beNil())
    }

    func testMissingClientID() {
        let opts = Options(clientId: nil, salesChannel: salesChannel, interfaceLanguage: interfaceLanguage, infoBundle: emptyBundle)
        expect { try opts.validate() }.to(throwError(ConfigurationError.missingClientId))
    }

    func testMissingSalesChannel() {
        let opts = Options(clientId: clientId, salesChannel: nil, interfaceLanguage: interfaceLanguage, infoBundle: emptyBundle)
        expect { try opts.validate() }.to(throwError(ConfigurationError.missingSalesChannel))
    }

    func testLoadValuesFromInfoPlist() {
        let opts = Options(infoBundle: testsBundle)

        expect(opts.clientId) == "CLIENT_ID_PLIST"
        expect(opts.salesChannel) == "SALES_CHANNEL_PLIST"
        expect(opts.interfaceLanguage) == "en"
        expect(opts.useSandboxEnvironment).to(beTrue())
    }

    func testOverrideValuesFromInfoPlist() {
        let opts = Options(clientId: clientId, salesChannel: salesChannel,
                           useSandboxEnvironment: useSandbox,
                           interfaceLanguage: interfaceLanguage,
                           infoBundle: testsBundle)

        expect(opts.clientId) == clientId
        expect(opts.salesChannel) == salesChannel
        expect(opts.interfaceLanguage) == interfaceLanguage
        expect(opts.useSandboxEnvironment) == useSandbox
    }

}
