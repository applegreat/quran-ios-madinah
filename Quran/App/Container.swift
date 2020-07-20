//
//  Container.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/20/16.
//
//  Quran for iOS is a Quran reading application for iOS.
//  Copyright (C) 2017  Quran.com
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
import BatchDownloader
import Moya
import SwiftyJSON
import UIKit

class Container {

    fileprivate static let DownloadsBackgroundIdentifier = "com.quran.ios.downloading.audio"

    // singleton as we cannot have more than background download service
    private static var downloadManager: DownloadManager! = nil // swiftlint:disable:this implicitly_unwrapped_optional

    init() {
        if Container.downloadManager == nil {
            let configuration = URLSessionConfiguration.background(withIdentifier: "DownloadsBackgroundIdentifier")
            configuration.timeoutIntervalForRequest = 60 * 5 // 5 minutes
            Container.downloadManager = URLSessionDownloadManager(maxSimultaneousDownloads: 600,
                                                                  configuration: configuration,
                                                                  persistence: createDownloadsPersistence())
        }
    }

    func createQarisDataRetriever() -> QariDataRetrieverType {
        return QariDataRetriever()
    }

    func createCreator<CreatedObject, Parameters>(
        _ creationClosure: @escaping (Parameters) -> CreatedObject) -> AnyCreator<Parameters, CreatedObject> {
        return AnyCreator(createClosure: creationClosure)
    }

    func createUserDefaults() -> UserDefaults {
        return UserDefaults.standard
    }

    func createSimplePersistence() -> SimplePersistence {
        return UserDefaultsSimplePersistence(userDefaults: createUserDefaults())
    }

    func createSuraLastAyahFinder() -> LastAyahFinder {
        return SuraBasedLastAyahFinder()
    }

    func createPageLastAyahFinder() -> LastAyahFinder {
        return PageBasedLastAyahFinder()
    }

    func createDownloadManager() -> DownloadManager {
        return Container.downloadManager
    }

    func createBookmarksPersistence() -> BookmarksPersistence {
        return SQLiteBookmarksPersistence()
    }

    func createLastPagesPersistence() -> LastPagesPersistence {
        return SQLiteLastPagesPersistence(simplePersistence: createSimplePersistence())
    }

    func createDownloadsPersistence() -> DownloadsPersistence {
        return SqliteDownloadsPersistence(filePath: Files.databasesPath.stringByAppendingPath("downloads.db"))
    }

    func createMoyaProvider() -> MoyaProvider<BackendServices> {
        return MoyaProvider()
    }

    func createNetworkManager<To>(parser: AnyParser<JSON, To>) -> AnyNetworkManager<To> {
        return AnyNetworkManager(MoyaNetworkManager(provider: createMoyaProvider(), parser: parser))
    }

    func createTranslationsParser() -> AnyParser<JSON, [Translation]> {
        return AnyParser(TranslationsParser())
    }

    func createActiveTranslationsPersistence() -> ActiveTranslationsPersistence {
        return SQLiteActiveTranslationsPersistence()
    }

    func createTranslationsRetriever() -> TranslationsRetrieverType {
        return TranslationsRetriever(
            networkManager: createNetworkManager(parser: createTranslationsParser()),
            persistence: createActiveTranslationsPersistence(),
            localRetriever: createLocalTranslationsRetriever())
    }

    func createLocalTranslationsRetriever() -> LocalTranslationsRetrieverType {
        return LocalTranslationsRetriever(
            persistence: createActiveTranslationsPersistence(),
            versionUpdater: createTranslationsVersionUpdater())
    }

    func createTranslationsVersionUpdater() -> TranslationsVersionUpdaterType {
        return TranslationsVersionUpdater(
            simplePersistence: createSimplePersistence(),
            persistence: createActiveTranslationsPersistence(),
            downloader: createDownloadManager(),
            versionPersistenceCreator: createCreator(createSQLiteDatabaseVersionPersistence))
    }

    func createSQLiteDatabaseVersionPersistence(filePath: String) -> DatabaseVersionPersistence {
        return SQLiteDatabaseVersionPersistence(filePath: filePath)
    }

    func createTranslationDeleter() -> TranslationDeleterType {
        return TranslationDeleter(
            persistence: createActiveTranslationsPersistence(),
            simplePersistence: createSimplePersistence())
    }

    func createQariAudioFileListRetrievalCreator() -> AnyCreator<Qari, QariAudioFileListRetrieval> {
        return QariAudioFileListRetrievalCreator().asAnyCreator()
    }

    func createAyahsAudioDownloader() -> AyahsAudioDownloaderType {
        return AyahsAudioDownloader(downloader: createDownloadManager(), creator: createQariAudioFileListRetrievalCreator())
    }

    func createDefaultSearchRecentsService() -> SearchRecentsService {
        return DefaultSearchRecentsService(persistence: createSimplePersistence())
    }

    func createReviewService() -> ReviewService {
        return ReviewService(simplePersistence: createSimplePersistence())
    }
}
