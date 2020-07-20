//
//  SurasViewController.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/19/16.
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
import GenericDataSources
import UIKit

protocol SurasPresentableListener: class {
    func navigateTo(quranPage: Int, lastPage: LastPage?)
}

class SurasViewController: BasePageSelectionViewController, SurasPresentable, SurasViewControllable {
    weak var listener: SurasPresentableListener?

    override var screen: Analytics.Screen { return .suras }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = lAndroid("quran_sura")
        tableView.ds_register(cellNib: SuraTableViewCell.self)
    }

    override func navigateTo(quranPage: Int, lastPage: LastPage?) {
        listener?.navigateTo(quranPage: quranPage, lastPage: lastPage)
    }

    func setSuras(_ surasArray: [JuzSuras]) {
        setJuzs(surasArray.map { $0.juz })

        for ds in dataSource.dataSources where ds is SurasDataSource {
            dataSource.remove(ds)
        }

        for suras in surasArray {
            let surasDataSource = SurasDataSource()
            surasDataSource.setDidSelect { [weak self] (ds, _, index) in
                let item = ds.item(at: index)
                self?.navigateTo(quranPage: item.startPageNumber, lastPage: nil)
            }
            surasDataSource.items = suras.suras
            dataSource.add(surasDataSource)
        }

        tableView?.reloadData()
    }
}
