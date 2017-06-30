import UIKit

protocol WaitingItem {
    func accept(_ visitor: WaitingCellFactory, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell
    func cellHeight(containerWidth: CGFloat) -> CGFloat
}

protocol WaitingLoadingItem: WaitingItem {
    var isLoaded: Bool { get set }
}

class GateItem: WaitingLoadingItem {

    let gate: HDKGate
    var isLoaded: Bool = false

    init(gate: HDKGate) {
        self.gate = gate
    }

    func accept(_ visitor: WaitingCellFactory, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return visitor.visit(self, collectionView: collectionView, indexPath: indexPath)
    }

    func cellHeight(containerWidth: CGFloat) -> CGFloat {
        return 48.0
    }
}

class OtherGatesItem: WaitingLoadingItem {

    var isLoaded: Bool = false

    func accept(_ visitor: WaitingCellFactory, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return visitor.visit(self, collectionView: collectionView, indexPath: indexPath)
    }

    func cellHeight(containerWidth: CGFloat) -> CGFloat {
        return 48.0
    }
}

class WaitingLongSearchItem: WaitingItem {
    func accept(_ visitor: WaitingCellFactory, collectionView: UICollectionView, indexPath: IndexPath) -> UICollectionViewCell {
        return visitor.visit(self, collectionView: collectionView, indexPath: indexPath)
    }

    func cellHeight(containerWidth: CGFloat) -> CGFloat {
        return WaitingLongSearchCell.preferredHeight(containerWidth: containerWidth)
    }
}
