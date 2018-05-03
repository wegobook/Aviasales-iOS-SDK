//
//  ASTContainerSearchFormViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTContainerSearchFormViewController.h"
#import "ASTSimpleSearchFormViewController.h"
#import "ASTComplexSearchFormViewController.h"


NS_ENUM(NSInteger, ASTContainerSearchFormSearchType) {
    ASTContainerSearchFormSearchTypeSimple  = 0,
    ASTContainerSearchFormSearchTypeComplex = 1
};


@interface ASTContainerSearchFormViewController () <HotelsSearchDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlContainerHeight;
@property (weak, nonatomic) IBOutlet UISegmentedControl *searchFormTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;

@property (nonatomic, strong) ASTSimpleSearchFormViewController *simpleSearchFormViewController;
@property (nonatomic, strong) ASTComplexSearchFormViewController *complexSearchFormViewController;

@property (nonatomic, weak) UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *currentChildViewController;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchButtonBottomLayoutConstraint;

@end

@implementation ASTContainerSearchFormViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    [InteractionManager shared].ticketsSearchForm = self;
    [self setupViewController];
    [self setSearchInfoBuilderStorageCallback];
    [self showChildViewController:self.simpleSearchFormViewController];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.searchButtonBottomLayoutConstraint.constant = self.bottomLayoutGuide.length;
}

#pragma mark - Setup

- (void)setupViewController {
    [self.view setBackgroundColor:[JRColorScheme searchFormBackgroundColor]];
    [self setupNavigationItems];
    [self setupSegmentedControl];
    [self setupSearchButton];
    [self setupChildViewControllers];
}

- (void)setupSegmentedControl {
    self.segmentedControlContainerHeight.constant = deviceSizeTypeValue(38.0, 44.0, 44.0, 44.0, 44.0);
    self.searchFormTypeSegmentedControl.tintColor = [JRColorScheme searchFormTintColor];
    [self.searchFormTypeSegmentedControl setTitle:NSLS(@"JR_SEARCH_FORM_SIMPLE_SEARCH_SEGMENT_TITLE") forSegmentAtIndex:ASTContainerSearchFormSearchTypeSimple];
    [self.searchFormTypeSegmentedControl setTitle:NSLS(@"JR_SEARCH_FORM_COMPLEX_SEARCH_SEGMENT_TITLE") forSegmentAtIndex:ASTContainerSearchFormSearchTypeComplex];
}

- (void)setupSearchButton {
    self.searchButton.tintColor = [UIColor whiteColor];
    self.searchButton.backgroundColor = [JRColorScheme actionColor];
    self.searchButton.layer.cornerRadius = 20.0;
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:NSLS(@"JR_SEARCH_FORM_SEARCH_BUTTON") attributes:@{NSFontAttributeName : [UIFont fontWithName:@".SFUIText-Bold" size:16.0]}];
    [self.searchButton setAttributedTitle:attributedString forState:UIControlStateNormal];
}

- (void)setupNavigationItems {
    self.navigationItem.title = NSLS(@"JR_SEARCH_FORM_TITLE");
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
}

- (void)setupChildViewControllers {
    self.simpleSearchFormViewController = [[ASTSimpleSearchFormViewController alloc] init];
    self.complexSearchFormViewController = [[ASTComplexSearchFormViewController alloc] init];
}

- (void)setSearchInfoBuilderStorageCallback {
    __weak typeof (self) weakSelf = self;
    [SearchInfoBuilderStorage shared].updateCallback = ^{
        [weakSelf updateSimpleSearchForm];
    };
}

#pragma mark - Upadte

- (void)updateSimpleSearchForm {
    [self showSimpleSearchForm];
    [self.searchFormTypeSegmentedControl setSelectedSegmentIndex:ASTContainerSearchFormSearchTypeSimple];
    [self.simpleSearchFormViewController update];
}

#pragma mark - Container Managment

- (void)showSimpleSearchForm {
    [self switchViewController:self.complexSearchFormViewController toViewController:self.simpleSearchFormViewController];
}

- (void)showComplexSearchForm {
    [self switchViewController:self.simpleSearchFormViewController toViewController:self.complexSearchFormViewController];
}

- (void)switchViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewControllerToHide toViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewControllerToShow {
    [self hideChildViewController:viewControllerToHide];
    [self showChildViewController:viewControllerToShow];
}

- (void)hideChildViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewController {
    [viewController willMoveToParentViewController:nil];
    [viewController.view removeFromSuperview];
    [viewController removeFromParentViewController];
}

- (void)showChildViewController:(UIViewController <ASTContainerSearchFormChildViewControllerProtocol> *)viewController {
    [self addChildViewController:viewController];
    viewController.view.frame = self.containerView.bounds;
    [self.containerView addSubview:viewController.view];
    [viewController didMoveToParentViewController:self];
    self.currentChildViewController = viewController;
}

#pragma mark - Actions

- (IBAction)searchFormTypeSegmentChanged:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case ASTContainerSearchFormSearchTypeSimple:
            [self showSimpleSearchForm];
            break;
        case ASTContainerSearchFormSearchTypeComplex:
            [self showComplexSearchForm];
            break;
    }
}

- (IBAction)searchButtonTapped:(UIButton *)sender {
    [self.currentChildViewController performSearch];
}

#pragma mark - HotelsSearchDelegate

- (void)updateSearchInfoWithDestination:(JRSDKAirport *)destination checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut passengers:(ASTPassengersInfo *)passengers {
    [self showSimpleSearchForm];
    [self.searchFormTypeSegmentedControl setSelectedSegmentIndex:ASTContainerSearchFormSearchTypeSimple];
    [self.simpleSearchFormViewController updateSearchInfoWithDestination:destination checkIn:checkIn checkOut:checkOut passengers:passengers];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.tabBarController setSelectedViewController:self.navigationController];
}

@end
