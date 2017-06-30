//
//  JRAirportSearchResultVC.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRAirportSearchResultVC.h"
#import "JRAirportPickerCellWithAirport.h"
#import "JRAirportPickerCellWithInfo.h"
#import "JRAirportPickerItem.h"

@interface JRAirportSearchResultVC () <AviasalesSearchPerformerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) AviasalesAirportsSearchPerformer *airportsSearchPerformer;
@property (nonatomic, strong) NSString *searchString;
@property (nonatomic, strong) NSArray <id <JRSDKLocation>> *searchResults;
@property (nonatomic, strong) NSArray <JRAirportPickerItem *> *items;
@property (nonatomic, assign) BOOL searching;

@property (nonatomic, copy) void (^selectionBlock)(JRAirportPickerItem *);

@end

@implementation JRAirportSearchResultVC

- (instancetype)initWithSelectionBlock:(void (^)(JRAirportPickerItem *))selectionBlock {
    self = [super init];
    if (self) {
        _selectionBlock = selectionBlock;
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupViewController];
}

#pragma mark - Setup 

- (void)setupViewController {
    [self setupAirportsSearchPerformer];
}

- (void)setupAirportsSearchPerformer {
    APISearchLocationType searchTypes = APISearchLocationTypeAirport | APISearchLocationTypeCity;
    AviasalesAirportsSearchPerformer *airportsSearchPerformer = [[AviasalesAirportsSearchPerformer alloc] initWithSearchLocationType:searchTypes delegate:self];
    self.airportsSearchPerformer = airportsSearchPerformer;
}

#pragma mark - Build

- (NSArray <JRAirportPickerItem *> *)buildItems {
    
    NSMutableArray <JRAirportPickerItem *> *items = [NSMutableArray array];
    
    for (id <JRSDKLocation> location in self.searchResults) {
        if ([location isKindOfClass:[JRSDKAirport class]]) {
            JRSDKAirport *airport = (JRSDKAirport *)location;
            if (airport.searchable) {
                JRAirportPickerItem *airportItem = [JRAirportPickerItem new];
                [airportItem setCellIdentifier:@"JRAirportPickerCellWithAirport"];
                [airportItem setItemContent:airport];
                [items addObject:airportItem];
            }
        }
    }
    
    if (self.searching) {
        JRAirportPickerItem *searchingItem = [JRAirportPickerItem new];
        [searchingItem setCellIdentifier:@"JRAirportPickerCellWithInfo"];
        [searchingItem setItemContent:NSLS(@"JR_AIRPORT_PICKER_SEARCHING_ON_SERVER_TEXT")];
        [items addObject:searchingItem];
    }
    
    return [items copy];
}

#pragma mark - AviasalesSearchPerformerDelegate

- (void)airportsSearchPerformer:(AviasalesAirportsSearchPerformer *)airportsSearchPerformer didFoundLocations:(NSArray<id<JRSDKLocation>> *)locations final:(BOOL)final {
    self.searching = !final;
    self.searchResults = locations;
    self.items = [self buildItems];
    [self.tableView reloadData];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    self.searchString = searchController.searchBar.text;
    self.searching = YES;
    [self.airportsSearchPerformer searchAirportsWithString:searchController.searchBar.text];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    JRAirportPickerItem *item = self.items[indexPath.row];
    
    id cell = [tableView dequeueReusableCellWithIdentifier:item.cellIdentifier];
    
    if (cell == nil) {
        cell = LOAD_VIEW_FROM_NIB_NAMED(item.cellIdentifier);
    }
    
    if ([cell isKindOfClass:[JRAirportPickerCellWithInfo class]]) {
        [[cell locationInfoLabel] setText:[item.itemContent uppercaseString]];
    } else if ([cell isKindOfClass:[JRAirportPickerCellWithAirport class]]) {
        [cell setSearchString:self.searchString];
        [cell setAirport:item.itemContent];
    }
    
    [cell updateBackgroundViewsForImagePath:indexPath inTableView:tableView];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.selectionBlock) {
        self.selectionBlock(self.items[indexPath.row]);
    }
}

@end
