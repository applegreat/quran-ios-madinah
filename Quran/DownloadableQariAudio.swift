//
//  DownloadableQariAudio.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/19/17.
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

struct DownloadableQariAudio: Downloadable {
    let audio: QariAudioDownload
    var response: DownloadBatchResponse?

    var isDownloaded: Bool { return audio.isDownloaded }
    var needsUpgrade: Bool { return false }
}

extension DownloadableQariAudio: Equatable {

    static func == (lhs: DownloadableQariAudio, rhs: DownloadableQariAudio) -> Bool {
        return lhs.audio.qari == rhs.audio.qari
    }
}
