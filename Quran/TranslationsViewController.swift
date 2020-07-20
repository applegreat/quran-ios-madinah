//
//  TranslationsViewController.swift
//  Quran
//
//  Created by Mohamed Afifi on 2/22/17.
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

protocol TranslationsListPresentableListener: class {
}

class TranslationsViewController: BaseTableViewController, TranslationsDataSourceDelegate, EditControllerDelegate,
                        TranslationsListPresentable, TranslationsListViewControllable {

    weak var listener: TranslationsListPresentableListener?

    override var screen: Analytics.Screen { return .translations }

    let editController = EditController(usesRightBarButton: true)
    private let dataSource: TranslationsDataSource
    private let translationsRetriever: TranslationsRetrieverType
    private let localTranslationsRetriever: LocalTranslationsRetrieverType

    init(translationsRetriever: TranslationsRetrieverType,
         localTranslationsRetriever: LocalTranslationsRetrieverType,
         dataSource: TranslationsDataSource) {
        self.translationsRetriever = translationsRetriever
        self.localTranslationsRetriever = localTranslationsRetriever
        self.dataSource = dataSource
        super.init(nibName: nil, bundle: nil)
        dataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        unimplemented()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = lAndroid("prefs_translations")

        tableView.sectionHeaderHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 70

        tableView.allowsSelection = false
        tableView.ds_register(headerFooterClass: JuzTableViewHeaderFooterView.self)
        tableView.ds_register(cellNib: TranslationTableViewCell.self)
        tableView.ds_useDataSource(dataSource)

        refreshControl = UIRefreshControl()
        // on iOS 11, it should show as white as it will be part of the navigation bar
        if #available(iOS 11, *) {
            refreshControl?.tintColor = .white
        }
        refreshControl?.addTarget(self, action: #selector(refreshData), for: .valueChanged)

        editController.configure(tableView: tableView, delegate: self, navigationItem: navigationItem)
        dataSource.downloadedDS.onItemsUpdated = { [weak self] _ in
            self?.editController.onEditableItemsUpdated()
        }
        dataSource.onEditingChanged = { [weak self] in
            self?.editController.onStartSwipingToEdit()
        }

        loadLocalData()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        showActivityIndicator()
        loadLocalData {
            self.refreshData()
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        editController.endEditing(animated)
    }

    func translationsDataSource(_ dataSource: AbstractDataSource, errorOccurred error: Error) {
        showErrorAlert(error: error)
    }

    @objc
    private func refreshData() {
        translationsRetriever
            .getTranslations()
            .done(on: .main) { [weak self] translations -> Void in
                self?.dataSource.setItems(items: translations)
                self?.tableView.reloadData()
            }.catchToAlertView(viewController: self)
            .finally(on: .main) { [weak self] in
                self?.refreshControl?.endRefreshing()
                self?.hideActivityIndicator()
            }
    }

    private func loadLocalData(completion: @escaping () -> Void = { }) {
        localTranslationsRetriever
            .getLocalTranslations()
            .done(on: .main) { [weak self] translations -> Void in
                self?.dataSource.setItems(items: translations)
                self?.tableView.reloadData()
            }.catchToAlertView(viewController: self)
            .finally {
                completion()
            }
    }

    func hasItemsToEdit() -> Bool {
        return !dataSource.downloadedDS.items.isEmpty
    }

    private func showActivityIndicator() {
        let activityIndicator = UIActivityIndicatorView(style: .white)
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        navigationItem.titleView = activityIndicator
    }

    private func hideActivityIndicator() {
        navigationItem.titleView = nil
    }
}
