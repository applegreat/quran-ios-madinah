//
//  BookmarksBuilder.swift
//  Quran
//
//  Created by Afifi, Mohamed on 3/31/19.
//  Copyright © 2019 Quran.com. All rights reserved.
//

import RIBs

// MARK: - Builder

protocol BookmarksBuildable: Buildable {
    func build(withListener listener: BookmarksListener) -> BookmarksRouting
}

final class BookmarksBuilder: Builder, BookmarksBuildable {

    func build(withListener listener: BookmarksListener) -> BookmarksRouting {
        let viewController = BookmarksTableViewController(
            simplePersistence: container.createSimplePersistence(),
            lastPagesPersistence: container.createLastPagesPersistence(),
            bookmarksPersistence: container.createBookmarksPersistence(),
            quranAyahTextPersistence: SQLiteQuranAyahTextPersistence()
        )
        let interactor = BookmarksInteractor(presenter: viewController)
        interactor.listener = listener
        return BookmarksRouter(interactor: interactor, viewController: viewController)
    }
}
