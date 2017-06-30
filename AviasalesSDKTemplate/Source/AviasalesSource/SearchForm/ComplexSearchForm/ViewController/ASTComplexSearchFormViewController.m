//
//  ASTComplexSearchFormViewController.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTComplexSearchFormViewController.h"
#import "ASTComplexSearchFormViewControllerProtocol.h"
#import "ASTComplexSearchFormPresenter.h"
#import "ASTComplexSearchFormViewModel.h"

#import "ASTComplexSearchFormHeaderView.h"
#import "ASTComplexSearchFormTableViewCell.h"
#import "ASTComplexSearchFormFooterView.h"
#import "ASTSearchFormPassengersView.h"

#import "JRAirportPickerVC.h"
#import "JRDatePickerVC.h"


@interface ASTComplexSearchFormViewController () <ASTComplexSearchFormViewControllerProtocol>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet ASTComplexSearchFormFooterView *footerView;
@property (weak, nonatomic) IBOutlet ASTSearchFormPassengersView *passengersView;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *passengersViewHeightConstraint;

@property (nonatomic, strong) ASTComplexSearchFormPresenter *presenter;
@property (nonatomic, strong) ASTComplexSearchFormViewModel *viewModel;

@end

@implementation ASTComplexSearchFormViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        _presenter = [[ASTComplexSearchFormPresenter alloc] initWithViewController:self];
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
    [self.presenter handleViewDidLoad];
}

#pragma mark - Setup

- (void)setupViewController {
    [self setupLayoutVariables];
    [self setupTableView];
    [self registerNibs];
}

- (void)setupLayoutVariables {
    self.passengersViewHeightConstraint.constant = deviceSizeTypeValue(45.0, 55.0, 85.0, 95.0, 95.0);
}

- (void)registerNibs {
    [self.tableView registerNib:[UINib nibWithNibName:[ASTComplexSearchFormTableViewCell hl_reuseIdentifier] bundle:[NSBundle mainBundle]] forCellReuseIdentifier:[ASTComplexSearchFormTableViewCell hl_reuseIdentifier]];
}

- (void)setupTableView {
    self.tableView.tableFooterView = self.footerView;
}

#pragma mark - Update

- (void)updateFooterView {
    
    __weak typeof(self) weakSelf = self;
    
    ASTComplexSearchFormFooterViewModel *footerViewModel = self.viewModel.footerViewModel;
    
    self.footerView.addButton.enabled = footerViewModel.shouldEnableAdd;
    self.footerView.addAction = ^(UIButton *sender) {
        [weakSelf.presenter handleAddTravelSegment];
    };
    
    self.footerView.removeButton.enabled = footerViewModel.shouldEnableRemove;
    self.footerView.removeAction = ^(UIButton *sender) {
        [weakSelf.presenter handleRemoveTravelSegment];
    };
}

- (void)updatePassengersView {
    
    ASTComplexSearchFormPassengersViewModel *passengersViewModel = self.viewModel.passengersViewModel;
    
    self.passengersView.adultsLabel.text = passengersViewModel.adults;
    self.passengersView.childrenLabel.text = passengersViewModel.children;
    self.passengersView.infantsLabel.text = passengersViewModel.infants;
    self.passengersView.travelClassLabel.text = passengersViewModel.travelClass;

    __weak typeof(self) weakSelf = self;
    self.passengersView.tapAction = ^(UIView *sender) {
        [weakSelf.presenter handlePickPassengers];
    };
}

#pragma mark - ASTComplexSearchFormViewControllerProtocol

- (void)updateWithViewModel:(ASTComplexSearchFormViewModel *)viewModel {
    self.viewModel = viewModel;
    [self.tableView reloadData];
    [self updateFooterView];
    [self updatePassengersView];
}

- (void)addRowAnimatedAtIndex:(NSInteger)index withViewModel:(ASTComplexSearchFormViewModel *)viewModel {
    self.viewModel = viewModel;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationRight];
    [self updateFooterView];
}

- (void)removeRowAnimatedAtIndex:(NSInteger)index withViewModel:(ASTComplexSearchFormViewModel *)viewModel {
    self.viewModel = viewModel;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
    [self updateFooterView];
}

- (void)showAirportPickerWithMode:(JRAirportPickerMode)mode forIndex:(NSInteger)index {
    [self showAirportPickerViewControllerWithMode:mode forIndex:index];
}

- (void)showDatePickerWithBorderDate:(NSDate *)borderDate selectedDate:(NSDate *)selectedDate forIndex:(NSInteger)index{
    [self showDatePickerViewControllerWithBorderDate:borderDate selectedDate:selectedDate forIndex:index];
}

- (void)showPassengersPickerWithInfo:(ASTPassengersInfo *)passengersInfo {
    [self showPassengersPickerViewControllerWithInfo:passengersInfo];
}

- (void)showErrorWithMessage:(NSString *)message {
    [self showErrorAlertWithMessage:message];
}

- (void)showWaitingScreenWithSearchInfo:(JRSDKSearchInfo *)searchInfо {
    [self showWaitingScreenViewControllerWithSeachInfo:searchInfо];
}

#pragma mark - ASTContainerSearchFormChildViewControllerProtocol

- (void)performSearch {
    [self.presenter handleSearch];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.viewModel.cellViewModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ASTComplexSearchFormCellViewModel *cellViewModel = self.viewModel.cellViewModels[indexPath.row];
    ASTComplexSearchFormTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[ASTComplexSearchFormTableViewCell hl_reuseIdentifier] forIndexPath:indexPath];
    [self setupCell:cell atIndex:indexPath.row withCellViewModel:cellViewModel];
    return cell;
}

#pragma mark - Cells

- (void)setupCell:(ASTComplexSearchFormTableViewCell *)cell atIndex:(NSInteger)index withCellViewModel:(ASTComplexSearchFormCellViewModel *)cellViewModel {
    
    [self setupCellSegment:cell.origin type:ASTComplexSearchFormCellSegmentTypeOrigin atIndex:index withCellSegmentViewModel:cellViewModel.origin];
    [self setupCellSegment:cell.destination type:ASTComplexSearchFormCellSegmentTypeDestination atIndex:index withCellSegmentViewModel:cellViewModel.destination];
    [self setupCellSegment:cell.departure type:ASTComplexSearchFormCellSegmentTypeDeparture atIndex:index withCellSegmentViewModel:cellViewModel.departure];
}

- (void)setupCellSegment:(ASTComplexSearchFormTableViewCellSegment *)cellSegment type:(ASTComplexSearchFormCellSegmentType)type atIndex:(NSInteger)index withCellSegmentViewModel:(ASTComplexSearchFormCellSegmentViewModel *)cellSegmentViewModel {
    
    cellSegment.iconImageView.hidden = !cellSegmentViewModel.placeholder;
    cellSegment.titleLabel.hidden = cellSegment.subtitleLabel.hidden = cellSegmentViewModel.placeholder;
    cellSegment.iconImageView.image = [UIImage imageNamed:cellSegmentViewModel.icon];
    cellSegment.titleLabel.text = cellSegmentViewModel.title;
    cellSegment.subtitleLabel.text = cellSegmentViewModel.subtitle;
    
    __weak typeof(self) weakSelf = self;
    cellSegment.tapAction = ^(UIView *sender) {
        [weakSelf.presenter handleSelectCellSegmentWithType:type atIndex:index];
    };
}

#pragma mark - Navigation

- (void)showAirportPickerViewControllerWithMode:(JRAirportPickerMode)mode forIndex:(NSInteger)index {
    
    __weak typeof(self) weakSelf = self;
    
    JRAirportPickerVC *airportPickerViewController = [[JRAirportPickerVC alloc] initWithMode:mode selectionBlock:^(JRSDKAirport *selectedAirport) {
        [weakSelf.presenter handleSelectAirport:selectedAirport withMode:mode atIndex:index];
        
    }];
    
    [self pushOrPresentBasedOnDeviceTypeWithViewController:airportPickerViewController animated:YES];
}

- (void)showDatePickerViewControllerWithBorderDate:(NSDate *)borderDate selectedDate:(NSDate *)selectedDate forIndex:(NSInteger)index {

    __weak typeof(self) weakSelf = self;
    
    JRDatePickerVC *datePickerViewController = [[JRDatePickerVC alloc] initWithMode:JRDatePickerModeDefault borderDate:borderDate firstDate:selectedDate secondDate:nil selectionBlock:^(NSDate *selectedDate) {
        [weakSelf.presenter handleSelectDate:selectedDate atIndex:index];
    }];
    
    [self pushOrPresentBasedOnDeviceTypeWithViewController:datePickerViewController animated:YES];
}

- (void)showPassengersPickerViewControllerWithInfo:(ASTPassengersInfo *)passengersInfo {
    
    __weak typeof(self) weakSelf = self;
    
    ASTPassengersPickerViewController *passengersPickerViewController = [[ASTPassengersPickerViewController alloc] initWithPassengersInfo:passengersInfo selection:^(ASTPassengersInfo *selectedPassengersInfo) {
        [weakSelf.presenter handleSelectPassengersInfo:selectedPassengersInfo];
    }];
    
    passengersPickerViewController.modalPresentationStyle = UIModalPresentationOverFullScreen;
    passengersPickerViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self presentViewController:passengersPickerViewController animated:YES completion:nil];
}

- (void)showWaitingScreenViewControllerWithSeachInfo:(JRSDKSearchInfo *)searchInfo {
    ASTWaitingScreenViewController *waitingScreenViewController = [[ASTWaitingScreenViewController alloc] initWithSearchInfo:searchInfo];
    [self.navigationController pushViewController:waitingScreenViewController animated:YES];
}

@end
