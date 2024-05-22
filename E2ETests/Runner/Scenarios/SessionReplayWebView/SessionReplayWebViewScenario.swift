/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-Present Datadog, Inc.
 */

import Foundation
import UIKit

import DatadogCore
import DatadogRUM
import DatadogSessionReplay

struct SessionReplayWebViewScenario: Scenario {
    func start(info: TestInfo) -> UIViewController {
        Datadog.initialize(
            with: .e2e(info: info),
            trackingConsent: .granted
        )

        RUM.enable(
            with: RUM.Configuration(
                applicationID: info.applicationID,
                uiKitViewsPredicate: DefaultUIKitRUMViewsPredicate(),
                uiKitActionsPredicate: DefaultUIKitRUMActionsPredicate()
            )
        )

        SessionReplay.enable(
            with: SessionReplay.Configuration(
                replaySampleRate: 100,
                defaultPrivacyLevel: .allow
            )
        )

        return SessionReplayWebViewController()
    }
}
