//
//  JRAirportPickerVC.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRColorScheme.h"
#import "JRAirportPickerCellWithAirport.h"
#import "JRAirportPickerCellWithInfo.h"
#import "JRAirportPickerItem.h"
#import "JRAirportPickerSectionTitle.h"
#import "JRAirportPickerVC.h"
#import "JRAirportSearchResultVC.h"
#import "JRNavigationController.h"
#import "JRSearchedAirportsManager.h"

#define kJRAirportPickerMaxSearchedCount (iPhone() ? 5 : 10)
#define kJRAirportPickerHeightForTitledHeader   44
#define kJRAirportPickerHeightForUntitledHeader 10
#define kJRAirportPicketHeightForRow 60
#define kJRAirportPickerBottomLineOffset 20
#define kJRAirportPickerMaxSearchedAirportListSize (iPhone() ? 7 : 15)

static NSString * const kJRAirportPickerCellWithInfo = @"JRAirportPickerCellWithInfo";
static NSString * const kJRAirportPickerCellWithAirport = @"JRAirportPickerCellWithAirport";

@interface JRAirportPickerVC () <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) JRAirportPickerMode mode;
@property (strong, nonatomic) JRSDKTravelSegmentBuilder *travelSegmentBuilder;
@property (strong, nonatomic) NSMutableArray <NSArray <JRAirportPickerItem *> *> *sections;
@property (strong, nonatomic) NSMutableDictionary *sectionTitles;
@property (strong, nonatomic) NSString *searchString;

@property (nonatomic, copy) void (^selectionBlock)(JRSDKAirport *);

@property (nonatomic, strong) UISearchController *searchController;

@end


@implementation JRAirportPickerVC

- (instancetype)initWithMode:(JRAirportPickerMode)mode selectionBlock:(void (^)(JRSDKAirport *))selectionBlock {
    
    self = [super init];
    
    if (self) {
        _mode = mode;
        _selectionBlock = selectionBlock;
    }
    
    return self;
}

- (void)setupTitle {
    
    NSString *title = nil;
    
    if (_mode == JRAirportPickerOriginMode) {
        title = NSLS(@"JR_AIRPORT_PICKER_ORIGIN_MODE_TITLE");
    } else if (_mode == JRAirportPickerDestinationMode) {
        title = NSLS(@"JR_AIRPORT_PICKER_DESTINATION_MODE_TITLE");
    }
    
    [self setTitle:title];
}

- (void)setupSearchController {
    
    __weak typeof(self) weakSelf = self;
    JRAirportSearchResultVC *airportSearchResultVC = [[JRAirportSearchResultVC alloc] initWithSelectionBlock:^(JRAirportPickerItem *item) {
        [weakSelf performSelection:item];
    }];
    
    UISearchController *searchController = [[UISearchController alloc] initWithSearchResultsController:airportSearchResultVC];

    searchController.searchResultsUpdater = airportSearchResultVC;
    
    searchController.searchBar.placeholder =  NSLS(@"JR_AIRPORT_PICKER_PLACEHOLDER_TEXT");

    self.tableView.tableHeaderView = searchController.searchBar;
    
    self.searchController = searchController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.definesPresentationContext = YES;

    [self setupTitle];
    [self setupSearchController];

    [self buildSections];
    
    if (_mode == JRAirportPickerOriginMode) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(rebuildTableView)
                                                     name:kAviasalesNearestAirportsManagerDidUpdateNotificationName object:nil];
    }
}

- (void) dealloc {
    [self.searchController.view removeFromSuperview];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Build

- (void)addNearestAirportsSection {

    NSMutableArray *nearestAirportsSection = [NSMutableArray new];
    
    NSString *nearestAirportsSectionTitle = NSLS(@"JR_AIRPORT_PICKER_NEAREST_AIRPORTS");
    NSArray *nearestAirports = [[[AviasalesSDK sharedInstance] nearestAirportsManager] airports];
    AviasalesNearestAirportsManagerStatus status = [[[AviasalesSDK sharedInstance] nearestAirportsManager] state];
    
    if (status == AviasalesNearestAirportsManagerIdle && nearestAirports.count == 0) {
        JRAirportPickerItem *noNearbyItem = [JRAirportPickerItem new];
        [noNearbyItem setCellIdentifier:kJRAirportPickerCellWithInfo];
        [noNearbyItem setItemContent:NSLS(@"JR_AIRPORT_PICKER_NO_NEAREST_AIRPORTS")];
        [nearestAirportsSection addObject:noNearbyItem];
    } else if (status == AviasalesNearestAirportsManagerReadingAirportData) {
        JRAirportPickerItem *updatingItem = [JRAirportPickerItem new];
        [updatingItem setCellIdentifier:kJRAirportPickerCellWithInfo];
        [updatingItem setItemContent:NSLS(@"JR_AIRPORT_PICKER_UPDATING_NEAREST_AIRPORTS")];
        [nearestAirportsSection addObject:updatingItem];
    } else if (status == AviasalesNearestAirportsManagerReadingError) {
        JRAirportPickerItem *readingErrorItem = [JRAirportPickerItem new];
        [readingErrorItem setCellIdentifier:kJRAirportPickerCellWithInfo];
        [readingErrorItem setItemContent:NSLS(@"JR_AIRPORT_PICKER_NEAREST_AIRPORTS_READING_ERROR")];
        [nearestAirportsSection addObject:readingErrorItem];
    } else {
        for (JRSDKAirport *airport in nearestAirports) {
            JRAirportPickerItem *airportItem = [JRAirportPickerItem new];
            [airportItem setCellIdentifier:kJRAirportPickerCellWithAirport];
            [airportItem setItemContent:airport];
            [nearestAirportsSection addObject:airportItem];
        }
    }
    
    if (nearestAirportsSection.count > 0) {
        [self.sections addObject:nearestAirportsSection];
        NSString *sectionKey = [NSString stringWithFormat:@"%@", @([self.sections indexOfObject:nearestAirportsSection])];
        self.sectionTitles[sectionKey] = nearestAirportsSectionTitle;
    }
}

- (void)addSearchedAirportsSection {
    
    NSArray *searchedAirports = [JRSearchedAirportsManager searchedAirports];
    
    NSMutableArray *searchedAirportsSection = [NSMutableArray new];
    
    NSString *searchedAirportsSectionTitle = NSLS(@"JR_AIRPORT_PICKER_SEARCHED_AIRPORTS");
    
    NSInteger numberOfSearchedAirports = 0;
    for (JRSDKAirport *airport in searchedAirports) {
        JRAirportPickerItem *airportItem = [JRAirportPickerItem new];
        [airportItem setCellIdentifier:kJRAirportPickerCellWithAirport];
        [airportItem setItemContent:airport];
        [searchedAirportsSection addObject:airportItem];
        numberOfSearchedAirports++;
        if (numberOfSearchedAirports >= kJRAirportPickerMaxSearchedAirportListSize) {
            break;
        }
    }
    
    if (searchedAirportsSection.count > 0) {
        [self.sections addObject:searchedAirportsSection];
        NSString *sectionKey = [NSString stringWithFormat:@"%@", @([self.sections indexOfObject:searchedAirportsSection])];
        self.sectionTitles[sectionKey] = searchedAirportsSectionTitle;
    }
}


- (void)buildSections {
    
    self.sections = [NSMutableArray new];
    self.sectionTitles = [NSMutableDictionary new];
    
    if (_mode == JRAirportPickerOriginMode) {
        [self addNearestAirportsSection];
    }
    
    [self addSearchedAirportsSection];
}

- (void)rebuildTableView {
    [self buildSections];
    [self.tableView reloadData];
}

#pragma mark - Selection

- (void)performSelection:(JRAirportPickerItem *)item {
    
    id object = item.itemContent;
    
    if ([object isKindOfClass:[JRSDKAirport class]]) {
        JRSDKAirport *airport = object;
        
        [JRSearchedAirportsManager markSearchedAirport:airport];

        if (self.selectionBlock) {
            self.selectionBlock(airport);
        }
        
        [self popOrDismissBasedOnDeviceTypeWithAnimated:YES];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sections[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JRAirportPickerItem *item = self.sections[indexPath.section][indexPath.row];
    
    id cell = [tableView dequeueReusableCellWithIdentifier:item.cellIdentifier];
    if (cell == nil) {
        cell = LOAD_VIEW_FROM_NIB_NAMED(item.cellIdentifier);
    }
    [cell setLeftOffset:kJRAirportPickerBottomLineOffset];
    [cell setBottomLineVisible:YES];
    
    if ([cell isKindOfClass:[JRAirportPickerCellWithInfo class]]) {
        [[cell locationInfoLabel] setText:[item.itemContent uppercaseString]];
        BOOL shouldHideActivityIndicator = self.tableView == tableView &&
        ![item.itemContent isEqualToString:NSLS(@"JR_AIRPORT_PICKER_UPDATING_NEAREST_AIRPORTS")];
        BOOL shouldEnableSelection = [item.itemContent isEqualToString:NSLS(@"JR_AIRPORT_PICKER_NEAREST_AIRPORTS_UPDATING_ERROR")];
        [cell setSelectionStyle:shouldEnableSelection ? UITableViewCellSelectionStyleDefault : UITableViewCellSelectionStyleNone];
        shouldHideActivityIndicator ? [cell stopActivityIndicator] : [cell startActivityIndicator];
    }
    if ([cell isKindOfClass:[JRAirportPickerCellWithAirport class]]) {
        [cell setSearchString:_searchString];
        [cell setAirport:item.itemContent];
    }
    [cell updateBackgroundViewsForImagePath:indexPath inTableView:tableView];
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    JRAirportPickerItem *item = self.sections[indexPath.section][indexPath.row];
  
    [self performSelection:item];
}

- (UIView *)mainViewForHeaderInSection:(NSInteger)section {
    
    NSString *sectionKey = [NSString stringWithFormat:@"%@", @(section)];
    NSString *title = self.sectionTitles[sectionKey];
    if (title) {
        JRAirportPickerSectionTitle *header = LOAD_VIEW_FROM_NIB_NAMED(@"JRAirportPickerSectionTitle");
        [header.titleLabel setText:title];
        header.backgroundColor = [UIColor clearColor];
        return header;
    } else {
        return [UIView new];
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    return [self mainViewForHeaderInSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    NSString *sectionKey = [NSString stringWithFormat:@"%@", @(section)];
    NSString *title = self.sectionTitles[sectionKey];
    return title ? kJRAirportPickerHeightForTitledHeader : kJRAirportPickerHeightForUntitledHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kJRAirportPicketHeightForRow;
}

@end
