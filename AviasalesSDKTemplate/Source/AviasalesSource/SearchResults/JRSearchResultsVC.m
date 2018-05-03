//
//  JRSearchResultsVC.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRSearchResultsVC.h"

#import "JRResultsTicketCell.h"

#import "JRFilter.h"
#import "JRNavigationController.h"

#import "JRTicketVC.h"

#import "JRSearchResultsList.h"
#import "JRTableManagerUnion.h"
#import "JRSearchInfoUtils.h"
#import "JRSearchResultsFlightSegmentCellLayoutParameters.h"

@interface JRSearchResultsVC () <JRSearchResultsListDelegate, SearchResultsCardListActionHandler, JRFilterDelegate>

@property (strong, nonatomic) JRSearchResultsList *resultsList;
@property (strong, nonatomic) SearchResultsCardList *cardList;
@property (strong, nonatomic) JRTableManagerUnion *tableManager;

@property (strong, nonatomic) JRSDKSearchInfo *searchInfo;
@property (strong, nonatomic) JRSDKSearchResult *response;

@property (nonatomic, strong) JRFilter *filter;

@property (nonatomic, assign) BOOL shouldShowMetropolitanResultsInfoAlert;

@property (nonatomic, assign) BOOL shouldSetTableViewInsets;
@property (nonatomic, assign) BOOL tableViewInsetsDidSet;

@property (strong, nonatomic) JRSearchResultsFlightSegmentCellLayoutParameters *flightSegmentLayoutParameters;

@end

@implementation JRSearchResultsVC

- (instancetype)initWithSearchInfo:(JRSDKSearchInfo *)searchInfo response:(JRSDKSearchResult *)response {
    
    self = [super init];
    
    if (self) {
        _searchInfo = searchInfo;
        _response = response;
        _shouldShowMetropolitanResultsInfoAlert = !response.searchResultInfo.isStrict;
    }
    
    return self;
}

#pragma mark - Properties

- (JRFilter *)filter {
    if (!_filter) {
        _filter = [[JRFilter alloc] initWithTickets:self.response.tickets searchInfo:self.searchInfo];
        _filter.delegate = self;
    }
    return  _filter;
}

- (JRSearchResultsList *)resultsList {
    if (!_resultsList) {
        _resultsList = [[JRSearchResultsList alloc] initWithCellNibName:[JRResultsTicketCell nibFileName]];
        _resultsList.flightSegmentLayoutParameters = [JRSearchResultsFlightSegmentCellLayoutParameters parametersWithTickets:[self tickets] font:[UIFont systemFontOfSize:12]];
        _resultsList.delegate = self;
    }
    return  _resultsList;
}

- (SearchResultsCardList *)cardList {
    if (!_cardList) {
        _cardList = [[SearchResultsCardList alloc] initWithSearchInfo:self.searchInfo delegate:self];
    }
    return _cardList;
}

- (JRTableManagerUnion *)tableManager {
    if (!_tableManager) {
        _tableManager = [[JRTableManagerUnion alloc] initWithFirstManager:self.resultsList secondManager:self.cardList secondManagerPositions:[self.cardList.indexes copy]];
    }
    return _tableManager;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewController];
    if (iPad()) {
        [self setFirstTicketSelected];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if (self.shouldSetTableViewInsets && !self.tableViewInsetsDidSet) {
        self.tableViewInsetsDidSet = YES;
        [self setupTableViewInsets];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    if (iPhone() && self.tableView.indexPathForSelectedRow) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }
    
    if (self.shouldShowMetropolitanResultsInfoAlert) {
        self.shouldShowMetropolitanResultsInfoAlert = NO;
        [self showMetropolitanResultsInfoAlert];
    }
}

#pragma mark - Setup 

- (void)setupViewController {

    if (@available(iOS 11.0, *)) {
        self.shouldSetTableViewInsets = NO;
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.shouldSetTableViewInsets = YES;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }

    [self setupNavigationItems];
    [self setupTableView];
}

- (void)setupNavigationItems {
    
    self.title = [JRSearchInfoUtils formattedIatasAndDatesExcludeYearComponentForSearchInfo:_searchInfo];
    
    SEL showFilters = @selector(showFilters:);
    
    if (iPhone()) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"filter_icon"] style:UIBarButtonItemStylePlain target:self action:showFilters];
    } else {
        self.parentViewController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLS(@"JR_FILTER_BUTTON") style:UIBarButtonItemStylePlain target:self action:showFilters];
    }
    
    self.navigationItem.backBarButtonItem = [UIBarButtonItem backBarButtonItem];
}

- (void)setupTableView {
    
    self.tableView.dataSource = self.tableManager;
    self.tableView.delegate = self.tableManager;
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, self.tableView.sectionHeaderHeight + self.tableView.sectionFooterHeight)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 0.0, self.tableView.sectionHeaderHeight)];
}

- (void)setupTableViewInsets {

    UIEdgeInsets tableViewInsets = self.tableView.contentInset;
    UIEdgeInsets insets = UIEdgeInsetsMake(tableViewInsets.top, tableViewInsets.left, self.bottomLayoutGuide.length, tableViewInsets.right);

    self.tableView.contentInset = insets;
    self.tableView.scrollIndicatorInsets = insets;
}

#pragma mark - Update

- (void)setFirstTicketSelected {

    NSIndexPath *indexPath = nil;

    for (NSInteger index = 0; index < self.tableView.numberOfSections; index++) {
        indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        if ([cell isKindOfClass:[JRResultsTicketCell class]]) {
            break;
        }
    }

    if (indexPath) {
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.tableManager tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark - Alert

- (void)showMetropolitanResultsInfoAlert {
    NSString *formattedIATAs = [JRSearchInfoUtils formattedIatasForSearchInfo:_searchInfo];
    NSString *message = [NSString stringWithFormat:NSLS(@"JR_SEARCH_RESULTS_NON_STRICT_MATCHED_ALERT_MESSAGE"), formattedIATAs];
    [self showAlertWithTitle:nil message:message cancelButtonTitle:NSLS(@"JR_OK_BUTTON")];
}

#pragma mark - <JRSearchResultsListDelegate>

- (NSArray<JRSDKTicket *> *)tickets {
    return self.filter.filteredTickets.array;
}

- (void)didSelectTicketAtIndex:(NSInteger)index {
    
    JRSDKTicket *ticket = [[self tickets] objectAtIndex:index];

    if (iPhone()) {
        JRTicketVC *const ticketVC = [[JRTicketVC alloc] initWithSearchInfo:self.searchInfo searchID:self.response.searchResultInfo.searchID];
        [ticketVC setTicket:ticket];
        [self.navigationController pushViewController:ticketVC animated:YES];
    } else {
        if (self.selectionBlock) {
            self.selectionBlock(ticket);
        }
    }
}

#pragma mark - <SearchResultsCardListActionHandler>

- (void)showPriceCalendarActionDidTrigger {
    PriceCalendarViewController *priceCalendarViewController = [[PriceCalendarViewController alloc] initWithSearchInfo:self.searchInfo];
    if (iPad()) {
        __weak typeof(self) weakSelf = self;
        priceCalendarViewController.dismissCallback = ^(JRSDKSearchInfo *searchInfo){
            ASTWaitingScreenViewController *waitingScreenViewController = [[ASTWaitingScreenViewController alloc] initWithSearchInfo:searchInfo];
            [weakSelf.navigationController setViewControllersWithRootAndViewController:waitingScreenViewController];
        };
    }
    [self pushOrPresentBasedOnDeviceTypeWithViewController:priceCalendarViewController animated:YES];
}

- (void)findHotelsActionDidTriggerAtIndex:(NSInteger)index {

    [[InteractionManager shared] applySearchHotelsInfo];

    [self.cardList removeHotellookCardItem];

    self.tableManager.secondManagerPositions = [self.cardList.indexes copy];

    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];

    if (selectedIndexPath.section >= index && selectedIndexPath.section > 0) {
        selectedIndexPath = [NSIndexPath indexPathForRow:0 inSection:selectedIndexPath.section - 1];
    }

    [self.tableView reloadData];

    if (iPad() && selectedIndexPath) {
        [self.tableView selectRowAtIndexPath:selectedIndexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
        [self.tableManager tableView:self.tableView didSelectRowAtIndexPath:selectedIndexPath];
    }
}

#pragma mark - Actions

- (void)showFilters:(id)sender {
    JRFilterMode mode = [JRSDKModelUtils isSimpleSearch:self.searchInfo] ? JRFilterSimpleSearchMode : JRFilterComplexMode;
    JRFilterVC *filterVC = [[JRFilterVC alloc] initWithFilter:self.filter forFilterMode:mode selectedTravelSegment:nil];
    JRNavigationController *filtersNavigationVC = [[JRNavigationController alloc] initWithRootViewController:filterVC];
    if (iPad()) {
        filtersNavigationVC.modalPresentationStyle = UIModalPresentationFormSheet;
    }
    [self presentViewController:filtersNavigationVC animated:YES completion:nil];
}

#pragma mark - JRFilterDelegate

- (void)filterDidUpdateFilteredObjects {
    [self.tableView reloadData];
    self.tableView.contentOffset = CGPointZero;
    BOOL isEmptyResults = [self tickets].count == 0;
    if (self.filterChangedBlock) {
        self.filterChangedBlock(isEmptyResults);
    }
    if (iPad() && !isEmptyResults) {
        [self setFirstTicketSelected];
    }
}

@end
