//
//  BookmarksManager.swift
//  Quran
//
//  Created by Mohamed Afifi on 3/19/17.
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

import Foundation
import PromiseKit

// TODO Review the design, it seems isBookmarked should be tight to a page
class BookmarksManager {
    private let bookmarksPersistence: BookmarksPersistence
    init(bookmarksPersistence: BookmarksPersistence) {
        self.bookmarksPersistence = bookmarksPersistence
    }

    private(set) var isBookmarked: Bool = false

    func calculateIsBookmarked(pageNumber: Int) -> Promise<Bool> {
        return DispatchQueue.global()
            .async(.promise) { self.bookmarksPersistence.isPageBookmarked(pageNumber) }
            .get(on: .main) { self.isBookmarked = $0 }
    }

    func toggleBookmarking(pageNumber: Int) -> Promise<Void> {
        isBookmarked = !isBookmarked

        if isBookmarked {
            Analytics.shared.bookmark(quranPage: pageNumber)
            return DispatchQueue.global().async(.promise) {
                try self.bookmarksPersistence.insertPageBookmark(pageNumber)
            }
        } else {
            Analytics.shared.unbookmark(quranPage: pageNumber)
            return DispatchQueue.global().async(.promise) {
                try self.bookmarksPersistence.removePageBookmark(pageNumber)
            }
        }
    }
}
