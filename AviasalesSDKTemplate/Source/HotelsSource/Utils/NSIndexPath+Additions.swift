//
//  NSIndexPath+Additions.swift
//  HotelLook
//
//  Created by Oleg on 02/09/15.
//  Copyright (c) 2015 Anton Chebotov. All rights reserved.
//

extension IndexPath {

    func previousIndexPaths(_ collectionView: UIScrollView, count: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var item = (self as NSIndexPath).item
        var section = (self as NSIndexPath).section

        for _ in 0..<count {
            if item <= 0 {
                if section == 0 {
                    break
                } else {
                    section -= 1
                    item = self.itemsCount(inSection: section, collectionView: collectionView)

                    if item == 0 {
                        continue
                    }
                }
            }

            item -= 1
            indexPaths.append(IndexPath(item: item, section: section))
        }

        return indexPaths
    }

    func nextIndexPaths(_ collectionView: UIScrollView, count: Int) -> [IndexPath] {
        var indexPaths = [IndexPath]()
        var item = (self as NSIndexPath).item
        var section = (self as NSIndexPath).section

        for _ in 0..<count {
            if item >= (self.itemsCount(inSection: section, collectionView: collectionView) - 1) {
                if section >= (self.sectionCount(collectionView) - 1) {
                    break
                } else {
                    section += 1
                    item = -1
                }
            }

            item += 1
            indexPaths.append(IndexPath(item: item, section: section))
        }

        return indexPaths
    }

    fileprivate func itemsCount(inSection section: Int, collectionView: UIScrollView) -> Int {
        var count = 0
        if let table = collectionView as? UITableView {
            count = table.numberOfRows(inSection: section)
        } else if let collection = collectionView as? UICollectionView {
            count = collection.numberOfItems(inSection: section)
        }

        return count
    }

    fileprivate func sectionCount(_ collectionView: UIScrollView) -> Int {
        var count = 0
        if let table = collectionView as? UITableView {
            count = table.numberOfSections
        } else if let collection = collectionView as? UICollectionView {
            count = collection.numberOfSections
        }

        return count
    }

}
