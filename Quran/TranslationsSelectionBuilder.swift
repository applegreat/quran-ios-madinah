//
//  TranslationsSelectionBuilder.swift
//  Quran
//
//  Created by Afifi, Mohamed on 4/7/19.
//  Copyright © 2019 Quran.com. All rights reserved.
//

import RIBs

protocol TranslationsSelectionBuildble: Buildable {
    func build(withListener listener: TranslationsListListener) -> TranslationsListRouting
}

final class TranslationsSelectionBuilder: Builder, TranslationsSelectionBuildble {

    func build(withListener listener: TranslationsListListener) -> TranslationsListRouting {
        let viewController = TranslationsSelectionViewController(
            translationsRetriever: container.createTranslationsRetriever(),
            localTranslationsRetriever: container.createLocalTranslationsRetriever(),
            dataSource: createTranslationsSelectionDataSource())
        let interactor = TranslationsListInteractor(presenter: viewController)
        interactor.listener = listener
        return TranslationsListRouter(interactor: interactor, viewController: viewController)
    }

    private func createTranslationsSelectionDataSource() -> TranslationsDataSource {
        let pendingDS = TranslationsBasicDataSource()
        let downloadedDS = TranslationsSelectionBasicDataSource(
            simplePersistence: container.createSimplePersistence())
        let dataSource = TranslationsSelectionDataSource(
            downloader: container.createDownloadManager(),
            deleter: container.createTranslationDeleter(),
            versionUpdater: container.createTranslationsVersionUpdater(),
            pendingDataSource: pendingDS,
            downloadedDataSource: downloadedDS)
        pendingDS.delegate = dataSource
        downloadedDS.delegate = dataSource
        return dataSource
    }
}
