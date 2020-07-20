//
//  MoreMenuViewController.swift
//  Quran
//
//  Created by Mohamed Afifi on 4/25/18.
//
//  Quran for iOS is a Quran reading application for iOS.
//  Copyright (C) 2018  Quran.com
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

enum QuranMode {
    case arabic
    case translation
}

protocol MoreMenuPresentableListener: class {
    func onQuranModeUpdated(to mode: QuranMode)
    func onTranslationsSelectionsTapped()
    func onIsWordPointerActiveUpdated(to isWordPointerActive: Bool)
    func onFontSizedUpdated(to fontSize: FontSize)
    func onThemeSelectedUpdated(to theme: Theme)
}

class MoreMenuViewController: BaseViewController, MoreMenuViewControllable, MoreMenuPresentable {

    override var screen: Analytics.Screen { return .moreMenu }

    weak var listener: MoreMenuPresentableListener?

    @IBOutlet weak var tableView: ThemedTableView!

    private let dataSource = CompositeDataSource(sectionType: .single)
    private let arabicTranslation = MoreArabicTranslationDataSource()
    private let selection = MoreTranslationsSelectionDataSource()
    private let pointer = MoreWordByWordPointerSelectionDataSource()
    private let fontSizeDS = MoreFontSizeDataSource()
    private let themeDS = MoreThemeDataSource()
    private let rotationDS = MoreRotationDataSource()

    init(model: MoreMenuModel) {
        super.init(nibName: nil, bundle: nil)

        arabicTranslation.itemHeight = 44
        selection.itemHeight = 44
        pointer.itemHeight = 44
        fontSizeDS.itemHeight = 44
        themeDS.itemHeight = 44
        rotationDS.itemHeight = 44

        arabicTranslation.items = [[
            SelectableItem(text: l("menu.arabic"), isSelected: model.mode == .arabic) { [weak self] _ in
                self?.arabicSelected()
            },
            SelectableItem(text: l("menu.translation"), isSelected: model.mode == .translation) { [weak self] _ in
                self?.translationsSelected()
            }
        ]]
        selection.items = [l("menu.select_translation")]
        pointer.items = [SelectableItem(text: l("menu.pointer"), isSelected: model.isWordPointerActive) { [weak self] item in
            self?.listener?.onIsWordPointerActiveUpdated(to: item.isSelected)
        }]
        setFontSizeItem(to: model.fontSize)
        setThemeItem(to: model.theme)
        rotationDS.items = [Void()]

        let selectionHandler = BlockSelectionHandler<String, MoreTranslationsSelectionTableViewCell>()
        selectionHandler.didSelectBlock = { [weak self] (_, _, _) in
            self?.listener?.onTranslationsSelectionsTapped()
        }
        selection.setSelectionHandler(selectionHandler)

        dataSource.add(arabicTranslation)

        if model.mode == .translation {
            dataSource.add(selection)
            dataSource.add(createEmptyDataSource())
            dataSource.add(fontSizeDS)
            dataSource.add(themeDS)
        } else {
            dataSource.add(createEmptyDataSource())
            dataSource.add(pointer)
            dataSource.add(createEmptyDataSource())
            dataSource.add(rotationDS)
            dataSource.add(themeDS)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.kind = .popoverSeparator
        tableView.separatorKind = .popoverSeparator

        tableView.ds_register(cellClass: EmptyTableViewCell.self)
        tableView.ds_register(cellNib: MoreArabicTranslationTableViewCell.self)
        tableView.ds_register(cellNib: MoreWordByWordPointerTableViewCell.self)
        tableView.ds_register(cellNib: MoreTranslationsSelectionTableViewCell.self)
        tableView.ds_register(cellNib: MoreFontSizeTableViewCell.self)
        tableView.ds_register(cellNib: ThemeSelectionTableViewCell.self)
        tableView.ds_register(cellNib: MoreRotationTableViewCell.self)
        tableView.ds_useDataSource(dataSource)

        updateSize()
    }

    private func updateSize() {
        var height: CGFloat = 0
        for section in 0..<dataSource.ds_numberOfSections() {
            for item in 0..<dataSource.ds_numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                height += dataSource.tableView(tableView, heightForRowAt: indexPath)
            }
        }
        preferredContentSize = CGSize(width: 280, height: height - 1)
    }

    private func remove(dataSource child: DataSource) {
        if let index = dataSource.index(of: child) {
            dataSource.remove(at: index)
            dataSource.ds_reusableViewDelegate?.ds_deleteItems(at: [IndexPath(item: index, section: 0)], with: .fade)
        }
    }

    private func insert(dataSource child: DataSource, at index: Int) {
        guard !dataSource.contains(child) else {
            return
        }
        dataSource.insert(child, at: index)
        let indexPath = IndexPath(item: index, section: 0)
        dataSource.ds_reusableViewDelegate?.ds_insertItems(at: [indexPath], with: .fade)
    }

    private func arabicSelected() {
        tableView.ds_performBatchUpdates({
            self.remove(dataSource: self.fontSizeDS)
            self.remove(dataSource: self.selection)
            self.insert(dataSource: self.createEmptyDataSource(), at: 1)
            self.insert(dataSource: self.pointer, at: 2)
            self.insert(dataSource: self.rotationDS, at: 4)
        }, completion: nil)

        quranModeUpdated(to: .arabic)
    }

    private func translationsSelected() {
        tableView.ds_performBatchUpdates({
            self.remove(dataSource: self.rotationDS)
            self.remove(dataSource: self.pointer)
            self.remove(dataSource: self.dataSource.dataSources[1]) // empty datasource
            self.insert(dataSource: self.selection, at: 1)
            self.insert(dataSource: self.fontSizeDS, at: 3)
        }, completion: nil)

        quranModeUpdated(to: .translation)
    }

    private func quranModeUpdated(to quranMode: QuranMode) {
        listener?.onQuranModeUpdated(to: quranMode)

        // hide word pointer
        setWordPointerActive(to: false)
        listener?.onIsWordPointerActiveUpdated(to: false)

        updateSize()
    }

    private func setWordPointerActive(to isWordPointerActive: Bool) {
        pointer.items[0].isSelected = isWordPointerActive
        let cell = pointer.ds_reusableViewDelegate?.ds_cellForItem(at: IndexPath(item: 0, section: 0)) as? MoreWordByWordPointerTableViewCell
        cell?.switchControl.setOn(isWordPointerActive, animated: true)
    }

    private func createEmptyDataSource() -> ThemedEmptyDataSource {
        let empty = ThemedEmptyDataSource()
        empty.itemHeight = 12
        empty.items = [Theme.Kind.popoverSeparator]
        return empty
    }

    private func setThemeItem(to theme: Theme) {
        themeDS.items = [
            ThemeItem(darkSelected: theme == .dark,
                      onDarkTapped: { [weak self] in self?.updateThemeItem(to: .dark) },
                      onLightTapped: { [weak self] in self?.updateThemeItem(to: .light) })
        ]
        themeDS.ds_reusableViewDelegate?.ds_reloadItems(at: [IndexPath(item: 0, section: 0)], with: .none)
    }

    private func updateThemeItem(to newTheme: Theme) {
        listener?.onThemeSelectedUpdated(to: newTheme)
        setThemeItem(to: newTheme)
    }

    private func setFontSizeItem(to fontSize: FontSize) {
        fontSizeDS.items = [
            FontSizeItem(isIncreaseEnabled: fontSize != .xLarge,
                         isDecreaseEnabled: fontSize != .xSmall,
                         increase: { [weak self] in self?.updateFontSize(to: fontSize.next) },
                         decrease: { [weak self] in self?.updateFontSize(to: fontSize.previous) })
        ]
        fontSizeDS.ds_reusableViewDelegate?.ds_reloadItems(at: [IndexPath(item: 0, section: 0)], with: .none)
    }

    private func updateFontSize(to newSize: FontSize?) {
        guard let newSize = newSize else {
            return
        }
        listener?.onFontSizedUpdated(to: newSize)
        setFontSizeItem(to: newSize)
    }
}

private struct SelectableItem {
    let text: String
    var isSelected: Bool
    let onSelection: (SelectableItem) -> Void
}

private struct FontSizeItem {
    var isIncreaseEnabled: Bool
    var isDecreaseEnabled: Bool
    var increase: () -> Void
    var decrease: () -> Void
}

private struct ThemeItem {
    var darkSelected: Bool
    var onDarkTapped: () -> Void
    var onLightTapped: () -> Void
}

private class MoreArabicTranslationDataSource: BasicDataSource<[SelectableItem], MoreArabicTranslationTableViewCell> {

    override func ds_collectionView(_ collectionView: GeneralCollectionView,
                                    configure cell: MoreArabicTranslationTableViewCell,
                                    with items: [SelectableItem],
                                    at indexPath: IndexPath) {
        cell.segmentedControl.removeAllSegments()
        for (index, item) in items.enumerated() {
            cell.segmentedControl.insertSegment(withTitle: item.text, at: index, animated: false)
            if item.isSelected {
                cell.segmentedControl.selectedSegmentIndex = index
            }
        }
        cell.onSegmentChanged = { [weak self] segment in
            var mutableItems = items
            for var item in mutableItems {
                item.isSelected = false
            }
            mutableItems[segment].isSelected = true
            self?.items[indexPath.item] = mutableItems
            mutableItems[segment].onSelection(mutableItems[segment])
        }
    }

    override func ds_collectionView(_ collectionView: GeneralCollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

private class MoreTranslationsSelectionDataSource: BasicDataSource<String, MoreTranslationsSelectionTableViewCell> {

    override func ds_collectionView(_ collectionView: GeneralCollectionView,
                                    configure cell: MoreTranslationsSelectionTableViewCell,
                                    with item: String,
                                    at indexPath: IndexPath) {
        cell.textLabel?.text = item
    }
}

private class MoreWordByWordPointerSelectionDataSource: BasicDataSource<SelectableItem, MoreWordByWordPointerTableViewCell> {

    override func ds_collectionView(_ collectionView: GeneralCollectionView,
                                    configure cell: MoreWordByWordPointerTableViewCell,
                                    with item: SelectableItem,
                                    at indexPath: IndexPath) {
        cell.textLabel?.text = item.text
        cell.switchControl.isOn = item.isSelected
        cell.onSwitchChanged = { [weak self] isOn in
            var mutableItem = item
            mutableItem.isSelected = isOn
            self?.items[indexPath.item] = mutableItem
            mutableItem.onSelection(mutableItem)
        }
    }

    override func ds_collectionView(_ collectionView: GeneralCollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

private class MoreFontSizeDataSource: BasicDataSource<FontSizeItem, MoreFontSizeTableViewCell> {

    override func ds_collectionView(_ collectionView: GeneralCollectionView,
                                    configure cell: MoreFontSizeTableViewCell,
                                    with item: FontSizeItem,
                                    at indexPath: IndexPath) {
        cell.increase.isEnabled = item.isIncreaseEnabled
        cell.decrease.isEnabled = item.isDecreaseEnabled
        cell.onIncreaseTapped = item.increase
        cell.onDecreaseTapped = item.decrease
    }

    override func ds_collectionView(_ collectionView: GeneralCollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

private class MoreRotationDataSource: BasicDataSource<Void, MoreRotationTableViewCell> {
    override func ds_collectionView(_ collectionView: GeneralCollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}

private class MoreThemeDataSource: BasicDataSource<ThemeItem, ThemeSelectionTableViewCell> {

    override func ds_collectionView(_ collectionView: GeneralCollectionView,
                                    configure cell: ThemeSelectionTableViewCell,
                                    with item: ThemeItem,
                                    at indexPath: IndexPath) {
        cell.darkSelected = item.darkSelected
        cell.onDarkTapped = item.onDarkTapped
        cell.onLightTapped = item.onLightTapped
    }
    override func ds_collectionView(_ collectionView: GeneralCollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return false
    }
}
