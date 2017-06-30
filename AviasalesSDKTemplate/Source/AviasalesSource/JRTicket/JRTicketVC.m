//
//  JRTicketVC.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRTicketVC.h"

#import "JRFlightCell.h"
#import "JRTransferCell.h"
#import "JRFlightsSegmentHeaderView.h"

#import "JRSearchInfoUtils.h"

#import "JRInfoPanelView.h"
#import "JRPriceUtils.h"

#import "NSLayoutConstraint+JRConstraintMake.h"

static const CGFloat kFlightCellHeight = 180.0;
static const CGFloat kTransforCellHeight = 56.0;
static const CGFloat kFlightsSegmentHeaderHeight = 94.0;

static const CGFloat kOffsetLimit = 50.0;
static const CGFloat kInfoPanelViewMaxHeightConstraint = 150.0;

static const NSTimeInterval kSearchResultsTTL = 15 * 60;

@interface JRTicketVC () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) JRSDKTicket *ticket;
@property (nonatomic, strong) JRSDKSearchInfo *searchInfo;
@property (nonatomic, strong) NSString *searchId;

@property (nonatomic, strong) JRInfoPanelView *infoPanelView;

@property (nonatomic, assign) BOOL tableViewInsetsDidSet;

@property (nonatomic, weak) IBOutlet UIView *infoPanelContainerView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *infoPanelViewHeightConstraint;

@end


@implementation JRTicketVC

- (instancetype)initWithSearchInfo:(JRSDKSearchInfo *)searchInfo searchID:(NSString *)searchID {
    self = [super init];
    if (self) {
        _searchInfo = searchInfo;
        _searchId = searchID;
    }
    return self;
}

- (void)dealloc {
    if (iPhone()) {
        [self.tableView removeObserver:self forKeyPath:@"contentOffset"];
    }
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewController];
    
    if (iPhone()) {
        [self.tableView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:nil];
    }
    
    [self updateContent];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    if (!self.tableViewInsetsDidSet) {
        self.tableViewInsetsDidSet = YES;
        [self setupTableViewInsets];
    }
}

#pragma mark - Properties

- (void)setTicket:(JRSDKTicket *)ticket {
    _ticket = ticket;
    [self updateContent];
}

#pragma mark - Setup

- (void)setupViewController {
    [self setupTableView];
    [self setupNavigationItems];
    [self setupInfoPanelView];
}

- (void)setupTableView {
    UINib *flightCellNib = [UINib nibWithNibName:@"JRFlightCell" bundle:AVIASALES_BUNDLE];
    UINib *transferCellNib = [UINib nibWithNibName:@"JRTransferCell" bundle:AVIASALES_BUNDLE];
    UINib *flightsSegmentHeaderNib = [UINib nibWithNibName:@"JRFlightsSegmentHeaderView" bundle:AVIASALES_BUNDLE];
    [self.tableView registerNib:flightCellNib forCellReuseIdentifier:@"JRFlightCell"];
    [self.tableView registerNib:transferCellNib forCellReuseIdentifier:@"JRTransferCell"];
    [self.tableView registerNib:flightsSegmentHeaderNib forHeaderFooterViewReuseIdentifier:@"JRFlightsSegmentHeaderView"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setupTableViewInsets {

    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    UIEdgeInsets insets = UIEdgeInsetsMake(tableViewInsets.top, tableViewInsets.left, self.bottomLayoutGuide.length, tableViewInsets.right);

    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

- (void)setupNavigationItems {
    self.title = [JRSearchInfoUtils formattedIatasAndDatesExcludeYearComponentForSearchInfo:_searchInfo];
}

- (void)setupInfoPanelView {
    self.infoPanelView = LOAD_VIEW_FROM_NIB_NAMED(@"JRInfoPanelView");
    self.infoPanelView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.infoPanelContainerView addSubview:self.infoPanelView];
    [self.infoPanelContainerView addConstraints:JRConstraintsMakeScaleToFill(self.infoPanelView, self.infoPanelContainerView)];    
}

#pragma mark - Update

- (void)updateContent {
    [self updateInfoPanelView];
    [self.tableView reloadData];
}

- (void)updateInfoPanelView {
    
    self.infoPanelView.ticket = self.ticket;
    
    __weak typeof(self) weakSelf = self;
    
    self.infoPanelView.buyHandler = ^() {
        [weakSelf buyTicketWithProposal:weakSelf.ticket.proposals.firstObject];
    };
    self.infoPanelView.showOtherAgencyHandler = ^() {
        [weakSelf showOtherAgencies];
    };
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.ticket.flightSegments.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger const flightsCount = self.ticket.flightSegments[section].flights.count;
    
    return (flightsCount > 0) ? 2 * flightsCount - 1 : flightsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell<JRTicketCellProtocol> *cell;
    NSInteger flightIndex = indexPath.row;
    
    if (indexPath.row % 2 == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"JRFlightCell" forIndexPath:indexPath];
        flightIndex -= flightIndex / 2;
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"JRTransferCell" forIndexPath:indexPath];
        flightIndex = (flightIndex + 1) / 2;
    }
    
    JRSDKFlight *const flight = self.ticket.flightSegments[indexPath.section].flights[flightIndex];
    [cell applyFlight:flight];
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    JRFlightsSegmentHeaderView *header = (JRFlightsSegmentHeaderView *)[tableView dequeueReusableHeaderFooterViewWithIdentifier:@"JRFlightsSegmentHeaderView"];
    header.flightSegment = self.ticket.flightSegments[section];
    
    return header;
}

#pragma mark - UITableViewDelegate methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        return kFlightCellHeight;
    } else {
        return kTransforCellHeight;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kFlightsSegmentHeaderHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.0;
}

#pragma mark - Private

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ((object == self.tableView) && [keyPath isEqualToString:@"contentOffset"]) {
        CGPoint newOffset = [[change valueForKey:NSKeyValueChangeNewKey] CGPointValue];
        CGPoint oldOffset = [[change valueForKey:NSKeyValueChangeOldKey] CGPointValue];
        CGFloat contentHeightLimit = self.view.bounds.size.height - kOffsetLimit;

        if ((newOffset.y != oldOffset.y) && (self.tableView.contentSize.height > contentHeightLimit)) {
            [self updateInfoPanelViewWithOffset:newOffset.y];
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)showOtherAgencies {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:AVIASALES_(@"JR_TICKET_BUY_IN_THE_AGENCY_BUTTON") message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    __weak typeof(self) weakSelf = self;
    
    for (JRSDKProposal *proposal in self.ticket.proposals) {
        
        NSString *title = [NSString stringWithFormat:@"%@ — %@", proposal.gate.label, [JRPriceUtils formattedPriceInUserCurrency:proposal.price]];
        
        UIAlertAction *buyAction = [UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [weakSelf buyTicketWithProposal:proposal];
        }];
        
        [alertController addAction:buyAction];
    }
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:AVIASALES_(@"JR_CANCEL_TITLE") style:UIAlertActionStyleCancel handler:nil];
    
    [alertController addAction:cancelAction];

    if (iPad()) {
        alertController.modalPresentationStyle = UIModalPresentationPopover;
        alertController.popoverPresentationController.sourceView = self.infoPanelView.showOtherAgenciesButton;
        alertController.popoverPresentationController.sourceRect = self.infoPanelView.showOtherAgenciesButton.bounds;
    }
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)updateInfoPanelViewWithOffset:(CGFloat)offset {
    
    CGFloat delta = MIN(kOffsetLimit, MAX(offset, 0.0));
    CGFloat percent = delta / kOffsetLimit;
    
    self.infoPanelViewHeightConstraint.constant = kInfoPanelViewMaxHeightConstraint - delta;
    self.infoPanelContainerView.layer.masksToBounds = !(percent > 0.0);

    [self.infoPanelContainerView setNeedsLayout];
    [self.infoPanelContainerView layoutIfNeeded];

    percent > 0.25 ? [self.infoPanelView collapse] : [self.infoPanelView expand];
}

- (BOOL)isTicketExpired {

    return [[NSDate date] timeIntervalSinceDate:self.ticket.searchResultInfo.receivingDate] > kSearchResultsTTL;
}

- (void)showTicketExpiredAlert {

    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLS(@"JR_TICKET_EXPIRED") message:nil preferredStyle:UIAlertControllerStyleAlert];

    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:NSLS(@"JR_NEW_SEARCH_TITLE") style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf.navigationController popToRootViewControllerAnimated:YES];
    }]];

    [alertController addAction:[UIAlertAction actionWithTitle:NSLS(@"JR_CANCEL_TITLE") style:UIAlertActionStyleCancel handler:nil]];

    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)showGateBrowserWithProposal:(JRSDKProposal *)proposal {

    ASTGateBrowserViewController *gateBrowserViewController = [[ASTGateBrowserViewController alloc] initWithTicketProposal:proposal searchID:self.searchId];

    JRNavigationController *naviagtionController = [[JRNavigationController alloc] initWithRootViewController:gateBrowserViewController];

    [self presentViewController:naviagtionController animated:YES completion:nil];
}

- (void)buyTicketWithProposal:(JRSDKProposal *)proposal {

    if ([self isTicketExpired]) {
        [self showTicketExpiredAlert];
    } else {
        [self showGateBrowserWithProposal:proposal];
    }
}

@end
