//
//  BottomDrawer.swift
//  BottomDrawer
//
//  Created by Seva Billevich on 18/03/15.
//  Copyright (c) 2015 Go Travel Un Limited. All rights reserved.
//

import UIKit

private let kHandleButtonHeight: CGFloat = 55
private let kActionButtonHeight: CGFloat = 50
private let kSeparatorHeight: CGFloat = 1 / UIScreen.main.scale
private let kShaddowPadding: CGFloat = 10
private let kDrawerNibName = "BottomDrawer"


class BottomDrawerView: UIView {
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        applyShadow()
    }

    func applyShadow() {
        let shadowPath = UIBezierPath(rect: CGRect(
            origin: CGPoint(x: -kShaddowPadding, y: 0),
            size: CGSize(width: bounds.size.width + kShaddowPadding * 2, height: bounds.size.height))
        )
        layer.shadowOffset = CGSize(width: 0, height: -1)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.29
        layer.shadowRadius = 3
        layer.shadowPath = shadowPath.cgPath
    }
}

public class BottomDrawer: UIViewController, UINavigationControllerDelegate {
    
    static var defaultTitleStyleAttributes: [String: AnyObject] = createDefaultStyleAttributes()
    static var defaultActionButtonStyle: ActionButtonStyle = ActionButtonStyle(
        height: kActionButtonHeight,
        backgroundColor: UIColor.white,
        selectedBackgroundColor: UIColor(white: 0.9, alpha: 1),
        titleAttributes: createActionButtonTitleAttributes()
    )
    static var defaultEnableHapticFeedback = false

    public var drawerHeight:CGFloat {
        get {
            var drawerHeight = contentHeight
            if attributedHandleTitle != nil {
                drawerHeight += kHandleButtonHeight + kSeparatorHeight
            }
            if attributedActionButtonTitle != nil {
                drawerHeight += actionButtonStyle.height + kSeparatorHeight
            }
            return drawerHeight
        }
    }
    public var contentHeight: CGFloat = 195 {
        didSet {
            updateDrawerHeight()
        }
    }
    public var drawerContainerOffset: CGFloat = 44
    public var maxOverlayAlpha: CGFloat = 0.35
    public var drawerAnimationDuration: TimeInterval = 0.3
    public var hidesNavigationBarPermanently = false

    public var titleAttributes = BottomDrawer.defaultTitleStyleAttributes {
        didSet {
            self.updateAttributedHandleTitle()
        }
    }
    
    public var handleTitle: String? {
        didSet {
            self.updateAttributedHandleTitle()
        }
    }

    public var attributedHandleTitle: NSAttributedString? {
        didSet {
            updateHandleButton()
        }
    }

    public var actionButtonTitle: String? {
        didSet {
            if let title = actionButtonTitle {
                let attributes = actionButtonStyle.titleAttributes
                attributedActionButtonTitle = NSAttributedString(string: title.uppercased(), attributes: attributes)
            } else {
                attributedActionButtonTitle = nil
            }
        }
    }

    public var attributedActionButtonTitle: NSAttributedString? {
        didSet {
            updateActionButton()
        }
    }

    public struct ActionButtonStyle {
        var height: CGFloat
        var backgroundColor: UIColor
        var selectedBackgroundColor: UIColor
        var titleAttributes: [String: AnyObject]
    }

    public var actionButtonStyle = BottomDrawer.defaultActionButtonStyle {
        didSet {
            updateActionButton()
            setupActionButtonBackground()
        }
    }

    public var enableHapticFeedback = BottomDrawer.defaultEnableHapticFeedback {
        didSet {
            updateHapticFeedback()
        }
    }

    public var actionClick: ((BottomDrawer) -> Void)?
    public var willDismissBlock: ((BottomDrawer, _ programmatically: Bool) -> Void)?
    public var dismissBlock: ((BottomDrawer, _ programmatically: Bool) -> Void)?

    private var contentController: UIViewController!
    private var navigationControllerClass: UINavigationController.Type!
    private var drawerNavigationController: UINavigationController?
    private var drawerWindow:UIWindow?
    private var _navDelegateProxy = _NavDelegateProxy()
    private var visible: Bool = false
    private var triggerHapticFeedback: (() -> Void)?
    @IBOutlet weak var drawerView: UIView!
    @IBOutlet weak var overlay: UIView!
    @IBOutlet weak var drawerBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var drawerContainerConstraint: NSLayoutConstraint!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var handleButton: UIButton!
    @IBOutlet weak var handleButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var topSeparatorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomSeparatorHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var topSeparator: UIView!

    @IBOutlet weak var bottomSeparator: UIView!

    @IBOutlet weak var actionButtonHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var actionButton: UIButton!

    public convenience init(viewController: UIViewController) {
        self.init(nibName: kDrawerNibName, viewController: viewController, navigationControllerClass: UINavigationController.self)
    }

    public convenience init(viewController: UIViewController, navigationControllerClass: UINavigationController.Type) {
        self.init(nibName: kDrawerNibName, viewController: viewController, navigationControllerClass: navigationControllerClass)
    }
    
    public init(nibName: String, viewController: UIViewController, navigationControllerClass: UINavigationController.Type) {
        super.init(nibName: nibName, bundle: nil)
        self.contentController = viewController
        self.navigationControllerClass = navigationControllerClass.self
        updateHapticFeedback()
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /**
    * Show drawer in window
    */
    public func show() {
        let prevKeyWindow = UIApplication.shared.keyWindow ?? UIApplication.shared.windows.first!
        drawerWindow = UIWindow(frame: prevKeyWindow.frame)

        drawerNavigationController = navigationControllerClass.init(rootViewController: self)
        drawerNavigationController?.isNavigationBarHidden = true

        drawerWindow?.backgroundColor = UIColor.clear
        drawerWindow?.rootViewController = drawerNavigationController
        drawerWindow?.windowLevel = UIWindowLevelStatusBar + 1
        drawerWindow?.isHidden = false
        drawerWindow?.makeKeyAndVisible()
    }

    /**
    * Show drawer in view
    */
    public func showInViewController(_ parentViewController: UIViewController) {
        drawerNavigationController = navigationControllerClass.init(rootViewController: self)
        drawerNavigationController?.isNavigationBarHidden = true
        parentViewController.addChildViewController(childController: drawerNavigationController, toFillView: parentViewController.view)
        visible = true
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.view.backgroundColor = UIColor.clear
        addChildViewController(childController: contentController, toFillView: container)
        updateHandleButton()
        updateActionButton()
        setupViews()

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            self.showDrawerAnimated()
        }

        _navDelegateProxy._originalDelegate = navigationController?.delegate
        _navDelegateProxy._newDelegate = self
        navigationController?.delegate = nil
        navigationController?.delegate = _navDelegateProxy
    }

    func setupViews() {
        if drawerContainerConstraint != nil {
            drawerContainerConstraint.constant = drawerContainerOffset
        }
        drawerHeightConstraint.constant = drawerHeight + drawerContainerOffset
        drawerBottomConstraint.constant = drawerHeight + drawerContainerOffset
        overlay.alpha = 0
        if let topSeparatorConstraint = topSeparatorHeightConstraint {
            topSeparatorConstraint.constant = kSeparatorHeight
        }
        let separatorColor = UIColor(hue: 0, saturation: 0, brightness: 0.79, alpha: 1)
        if topSeparator != nil {
            topSeparator.backgroundColor = separatorColor
        }
        if bottomSeparator != nil {
            bottomSeparator.backgroundColor = separatorColor
        }

        setupActionButtonBackground()
    }

    func setupActionButtonBackground() {
        guard let actionButton = actionButton
            else { return }
        actionButton.setBackgroundImage(UIImage(color: actionButtonStyle.backgroundColor), for: .normal)
        actionButton.setBackgroundImage(UIImage(color: actionButtonStyle.selectedBackgroundColor), for: .highlighted)
    }

    func showDrawerAnimated() {
        triggerHapticFeedback?()
        UIView.animate(withDuration: drawerAnimationDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0, options: .curveEaseIn, animations: {
            self.drawerBottomConstraint.constant = self.drawerContainerOffset
            self.view.layoutIfNeeded()
            self.overlay.alpha = self.maxOverlayAlpha
        }, completion: nil)
        visible = true
    }

    func hideDrawerAnimated(completionBlock: @escaping () -> Void) {
        UIView.animate(withDuration: drawerAnimationDuration, delay: 0, options: .curveEaseIn, animations: {
            self.drawerBottomConstraint.constant = self.drawerHeight + self.drawerContainerOffset
            self.view.layoutIfNeeded()
            self.overlay.alpha = 0
            }, completion: { [weak self]
                Bool in
                self?.visible = false
                completionBlock()
        })
    }

    public func dismissDrawer() {
        dismissDrawer(programmatically: true)
    }
    public func isVisible() -> Bool {
        return visible
    }
    @IBAction internal func handleButtonClick() {
        dismissDrawer(programmatically: false)
    }

    @objc(dismissDrawerProgrammatically:)
    public func dismissDrawer(programmatically: Bool) {
        navigationController?.delegate = _navDelegateProxy._originalDelegate

        willDismissBlock?(self, programmatically)

        hideDrawerAnimated {
            self.deleteChildViewController(self.contentController)
            self.drawerWindow?.isHidden = true
            self.drawerWindow = nil
            self.drawerNavigationController?.parent?.deleteChildViewController(self.drawerNavigationController)
            self.drawerNavigationController?.view.isHidden = true
            self.drawerNavigationController = nil
            self.dismissBlock?(self, programmatically)
        }
    }

// MARK: - gesture recognizer handling

    @IBAction func handlePan(recognizer: UIPanGestureRecognizer) {
        let location = recognizer.location(in: self.view).y
        let velocity = recognizer.velocity(in: self.view).y
        var newBottomOffset = -1 * (self.view.bounds.height - location - self.drawerHeight - self.drawerContainerOffset)
        if newBottomOffset < drawerContainerOffset  {
            //slow down pan tracking
            newBottomOffset = newBottomOffset / 2 + drawerContainerOffset / 2
        }
        if newBottomOffset < 0 {
            newBottomOffset = 0
        }
        switch recognizer.state {
        case .began:
            UIView.animate(withDuration: drawerAnimationDuration, delay: 0, options: .curveEaseOut, animations: {
                self.updateBottomOffset(newBottomOffset: newBottomOffset)
                self.view.layoutIfNeeded()
            }, completion: {
                    Bool in
            })
        case .changed:
            updateBottomOffset(newBottomOffset: newBottomOffset)
        case .ended:
            if velocity > 100 || (velocity >= 0 && newBottomOffset > self.drawerContainerOffset) {
                self.dismissDrawer(programmatically: false)
            } else {
                self.showDrawerAnimated()
            }
        default:
            break
        }
    }

    @IBAction func didClickActionButton(sender: AnyObject) {
        actionClick?(self)
    }

    private func updateHandleButton() {
        guard handleButton != nil else { return } //not loaded yet
        if let title = attributedHandleTitle {
            handleButton.setAttributedTitle(title, for: .normal)
            handleButtonHeightConstraint.constant = kHandleButtonHeight
            handleButton.contentEdgeInsets = UIEdgeInsetsMake(2, 1, 0, 0)
            handleButton.alpha = 1
        } else {
            handleButton.setAttributedTitle(nil, for: .normal)
            handleButtonHeightConstraint.constant = 0
            handleButton.alpha = 0
        }
        updateDrawerHeight()
    }

    private func updateActionButton() {
        guard actionButton != nil else { return } //not loaded yet
        if let title = attributedActionButtonTitle {
            actionButton.setAttributedTitle(title, for: .normal)
            actionButtonHeightConstraint.constant = actionButtonStyle.height
            bottomSeparatorHeightConstraint.constant = kSeparatorHeight
            actionButton.alpha = 1
        } else {
            actionButton.setAttributedTitle(nil, for: .normal)
            actionButtonHeightConstraint.constant = 0
            if bottomSeparatorHeightConstraint != nil {
                bottomSeparatorHeightConstraint.constant = 0
            }
            actionButton.alpha = 0
        }
        updateDrawerHeight()
    }

    func updateBottomOffset(newBottomOffset: CGFloat) {
        self.drawerBottomConstraint.constant = newBottomOffset
        self.overlay.alpha = self.maxOverlayAlpha * ( (self.drawerContainerOffset - newBottomOffset) / self.drawerHeight + 1 )
    }

    private func updateDrawerHeight() {
        drawerHeightConstraint?.constant = drawerHeight + drawerContainerOffset
    }
   
    private func updateAttributedHandleTitle() {
        if let title = handleTitle {
            attributedHandleTitle = NSAttributedString(string: title.uppercased(), attributes: self.titleAttributes)
        } else {
            attributedHandleTitle = nil
        }
    }

    private func updateHapticFeedback() {
        if enableHapticFeedback {
            if #available(iOS 10.0, *) {
                let impactGenerator = UIImpactFeedbackGenerator.init(style: .light)
                impactGenerator.prepare()
                triggerHapticFeedback = { impactGenerator.impactOccurred() }
            }
        } else {
            triggerHapticFeedback = nil
        }
    }

// MARK: navigation controller delegate

    class _NavDelegateProxy: NSObject, UINavigationControllerDelegate {
        weak var _originalDelegate: UINavigationControllerDelegate?
        weak var _newDelegate: UINavigationControllerDelegate?

        override func responds(to aSelector: Selector!) -> Bool {
            return super.responds(to: aSelector) || _originalDelegate?.responds(to: aSelector) == true
        }

        override func forwardingTarget(for aSelector: Selector!) -> Any? {
            if _originalDelegate?.responds(to: aSelector) == true {
                return _originalDelegate
            }
            else {
                return super.forwardingTarget(for: aSelector) as AnyObject?
            }
        }

        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            _originalDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
            _newDelegate?.navigationController?(navigationController, willShow: viewController, animated: animated)
        }
    }

    public func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        if viewController.isEqual(self) {
            navigationController.setNavigationBarHidden(true, animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.15) {
                self.drawerWindow?.windowLevel = UIWindowLevelStatusBar + 1
            }
        } else {
            navigationController.setNavigationBarHidden(hidesNavigationBarPermanently, animated: true)
            drawerWindow?.windowLevel = UIWindowLevelNormal
        }
    }
}

/// MARK: child view controller handling
private extension UIViewController {

    func addChildViewController(childController: UIViewController?, toFillView containerView: UIView) {
        guard let childController = childController else { return }
        self.addChildViewController(childController)
        containerView.addSubview(childController.view)
        childController.view.frame = CGRect(origin: .zero, size: containerView.bounds.size)
        childController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        childController.didMove(toParentViewController: self)
    }

    func deleteChildViewController(childController: UIViewController?) {
        childController?.willMove(toParentViewController: nil)
        childController?.view.removeFromSuperview()
        childController?.removeFromParentViewController()
    }
}

private func createDefaultStyleAttributes() -> [String: AnyObject] {
    return [
        NSFontAttributeName : UIFont.systemFont(ofSize: 16),
        NSForegroundColorAttributeName: UIColor(hue: 0, saturation: 0, brightness: 0.36, alpha: 1),
        NSKernAttributeName: 1.0 as AnyObject
    ]
}
private func createActionButtonTitleAttributes() -> [String: AnyObject] {
    return [
        NSFontAttributeName : UIFont.systemFont(ofSize: 16),
        NSForegroundColorAttributeName: UIColor(hue: 0, saturation: 0, brightness: 0.5, alpha: 1),
        NSKernAttributeName: 1.0 as AnyObject
    ]
}
