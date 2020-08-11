/*
 * Unless explicitly stated otherwise all files in this repository are licensed under the Apache License Version 2.0.
 * This product includes software developed at Datadog (https://www.datadoghq.com/).
 * Copyright 2019-2020 Datadog, Inc.
 */

import Foundation

/// Obtains a subdirectory in `/Library/Caches` where log files are stored.
internal func obtainLoggingFeatureDirectory() throws -> Directory {
    return try Directory(withSubdirectoryPath: "com.datadoghq.logs/v1")
}

/// Creates and owns componetns enabling logging feature.
/// Bundles dependencies for other logging-related components created later at runtime  (i.e. `Logger`).
internal final class LoggingFeature {
    /// Single, shared instance of `LoggingFeature`.
    internal static var instance: LoggingFeature?

    // MARK: - Configuration

    let configuration: Datadog.ValidConfiguration

    // MARK: - Dependencies

    let dateProvider: DateProvider
    let userInfoProvider: UserInfoProvider
    let networkConnectionInfoProvider: NetworkConnectionInfoProviderType
    let carrierInfoProvider: CarrierInfoProviderType

    // MARK: - Components

    static let featureName = "logging"
    /// NOTE: any change to data format requires updating the directory url to be unique
    static let dataFormat = DataFormat(prefix: "[", suffix: "]", separator: ",")

    /// Log files storage.
    let storage: FeatureStorage
    /// Logs upload worker.
    let upload: FeatureUpload

    // MARK: - Initialization

    convenience init(
        directory: Directory,
        commonDependencies: FeaturesCommonDependencies
    ) {
        let storage = FeatureStorage(
            featureName: LoggingFeature.featureName,
            dataFormat: LoggingFeature.dataFormat,
            directory: directory,
            commonDependencies: commonDependencies
        )
        let upload = FeatureUpload(
            featureName: LoggingFeature.featureName,
            storage: storage,
            uploadHTTPHeaders: HTTPHeaders(
                headers: [
                    .contentTypeHeader(contentType: .applicationJSON),
                    .userAgentHeader(
                        appName: commonDependencies.configuration.applicationName,
                        appVersion: commonDependencies.configuration.applicationVersion,
                        device: commonDependencies.mobileDevice
                    )
                ]
            ),
            uploadURLProvider: UploadURLProvider(
                urlWithClientToken: commonDependencies.configuration.logsUploadURLWithClientToken,
                queryItemProviders: [
                    .ddsource(),
                    .batchTime(using: commonDependencies.dateProvider)
                ]
            ),
            commonDependencies: commonDependencies
        )
        self.init(
            storage: storage,
            upload: upload,
            commonDependencies: commonDependencies
        )
    }

    init(
        storage: FeatureStorage,
        upload: FeatureUpload,
        commonDependencies: FeaturesCommonDependencies
    ) {
        // Configuration
        self.configuration = commonDependencies.configuration

        // Bundle dependencies
        self.dateProvider = commonDependencies.dateProvider
        self.userInfoProvider = commonDependencies.userInfoProvider
        self.networkConnectionInfoProvider = commonDependencies.networkConnectionInfoProvider
        self.carrierInfoProvider = commonDependencies.carrierInfoProvider

        // Initialize stacks
        self.storage = storage
        self.upload = upload
    }
}
