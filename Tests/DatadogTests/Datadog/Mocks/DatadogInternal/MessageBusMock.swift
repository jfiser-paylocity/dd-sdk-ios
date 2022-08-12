/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation
import XCTest

@testable import Datadog

internal struct FeatureMessageReceiverMock: FeatureMessageReceiver {
    typealias ReceiverClosure = (String, [String: Any]?) -> Void

    /// Test expectation that will be fullfilled when a message is received.
    internal var expectation: XCTestExpectation?

    internal var receiver: ReceiverClosure?

    /// Creates a Feature Message Receiever  mock.
    /// - Parameters:
    ///   - expectation: Test expectation that will be fullfilled when a message is
    ///                  received.
    ///   - receiver: The receiver closure called when receiving a message.
    init(
        expectation: XCTestExpectation? = nil,
        receiver: ReceiverClosure? = nil
    ) {
        self.expectation = expectation
        self.receiver = receiver
    }

    func receive(message: String, attributes: [String: Any]?) {
        receiver?(message, attributes)
        expectation?.fulfill()
    }
}
