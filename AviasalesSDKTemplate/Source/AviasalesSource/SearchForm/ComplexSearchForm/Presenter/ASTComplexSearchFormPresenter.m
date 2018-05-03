//
//  ASTComplexSearchFormPresenter.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "ASTComplexSearchFormPresenter.h"
#import "ASTComplexSearchFormViewControllerProtocol.h"
#import "ASTComplexSearchFormViewModel.h"
#import "JRSearchInfoUtils.h"
#import "DateUtil.h"

static NSInteger const minTravelSegments = 1;
static NSInteger const maxTravelSegments = 8;

@interface ASTComplexSearchFormPresenter ()

@property (nonatomic, weak) id <ASTComplexSearchFormViewControllerProtocol> viewController;

@property (nonatomic, strong) JRSDKSearchInfoBuilder *searchInfoBuilder;
@property (nonatomic, strong) NSMutableOrderedSet <JRSDKTravelSegmentBuilder *> *travelSegmentBuilders;

@end

@implementation ASTComplexSearchFormPresenter

- (instancetype)initWithViewController:(id<ASTComplexSearchFormViewControllerProtocol>)viewController {
    self = [super init];
    if (self) {
        _viewController = viewController;
    }
    return self;
}

- (void)handleViewDidLoad {
    [self restoreSearchInfoBuilder];
    [self createTravelSegmentBuilders];
    [self updateExpiredDepartureDates];
    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleSelectCellSegmentWithType:(ASTComplexSearchFormCellSegmentType)type atIndex:(NSInteger)index {
    switch (type) {
        case ASTComplexSearchFormCellSegmentTypeOrigin:
            [self.viewController showAirportPickerWithType:ASAirportPickerTypeOrigin forIndex:index];
            break;
        case ASTComplexSearchFormCellSegmentTypeDestination:
            [self.viewController showAirportPickerWithType:ASAirportPickerTypeDestination forIndex:index];
            break;
        case ASTComplexSearchFormCellSegmentTypeDeparture:
            [self.viewController showDatePickerWithBorderDate:[self borderDateAtIndex:index] selectedDate:[self departureDateAtIndex:index] forIndex:index];
            break;
    }
}

- (void)handleAddTravelSegment {
    NSInteger index = self.travelSegmentBuilders.count;
    [self.travelSegmentBuilders addObject:[JRSDKTravelSegmentBuilder new]];
    [self.viewController addRowAnimatedAtIndex:index withViewModel:[self buildViewModel]];
}

- (void)handleRemoveTravelSegment {
    [self.travelSegmentBuilders removeObject:self.travelSegmentBuilders.lastObject];
    NSInteger index = self.travelSegmentBuilders.count;
    [self.viewController removeRowAnimatedAtIndex:index withViewModel:[self buildViewModel]];
}

- (void)handlePickPassengers {
    [self.viewController showPassengersPickerWithInfo:[self buildPassengersInfo]];
}

- (void)handleSelectAirport:(JRSDKAirport *)selectedAirport withType:(ASAirportPickerType)type atIndex:(NSInteger)index {
    if (self.travelSegmentBuilders.count > index) {
        switch (type) {
            case ASAirportPickerTypeOrigin:
                self.travelSegmentBuilders[index].originAirport = selectedAirport;
                break;
            case ASAirportPickerTypeDestination:
                self.travelSegmentBuilders[index].destinationAirport = selectedAirport;
                break;
        }
        [self.viewController updateWithViewModel:[self buildViewModel]];
    }
}

- (void)handleSelectDate:(NSDate *)selectedDate atIndex:(NSInteger)index {
    if (self.travelSegmentBuilders.count > index) {
        self.travelSegmentBuilders[index].departureDate = selectedDate;
        [self updateDatesFromIndex:index withDate:selectedDate];
        [self.viewController updateWithViewModel:[self buildViewModel]];
    }
}

- (void)handleSelectPassengersInfo:(ASTPassengersInfo *)selectedPassengersInfo {
    self.searchInfoBuilder.adults = selectedPassengersInfo.adults;
    self.searchInfoBuilder.children = selectedPassengersInfo.children;
    self.searchInfoBuilder.infants = selectedPassengersInfo.infants;
    self.searchInfoBuilder.travelClass = selectedPassengersInfo.travelClass;
    [self.viewController updateWithViewModel:[self buildViewModel]];
}

- (void)handleSearch {
    JRSDKSearchInfo *searchInnfo = [self buildSearchInfo];
    if (searchInnfo) {
        [self.viewController showWaitingScreenWithSearchInfo:searchInnfo];
        [self saveSearchInfoBuilder];
        [[InteractionManager shared] clearSearchHotelsInfo];
    }
}

#pragma mark - Build

- (ASTPassengersInfo *)buildPassengersInfo {
    
    NSInteger adults = self.searchInfoBuilder.adults;
    NSInteger children = self.searchInfoBuilder.children;
    NSInteger infants = self.searchInfoBuilder.infants;
    JRSDKTravelClass travelClass = self.searchInfoBuilder.travelClass;
    
    return [[ASTPassengersInfo alloc] initWithAdults:adults children:children infants:infants travelClass:travelClass];
}

- (ASTComplexSearchFormViewModel *)buildViewModel {
    
    ASTComplexSearchFormViewModel *viewModel = [ASTComplexSearchFormViewModel new];
    
    viewModel.cellViewModels = [self buildCellViewModels];
    viewModel.footerViewModel = [self buildFooterViewModel];
    viewModel.passengersViewModel = [self buildPassengersViewModel];
    
    return viewModel;
}

- (NSArray <ASTComplexSearchFormCellViewModel *> *)buildCellViewModels {
    NSMutableArray <ASTComplexSearchFormCellViewModel *> *cellViewModels = [[NSMutableArray alloc] initWithCapacity:self.travelSegmentBuilders.count];
    for (JRSDKTravelSegmentBuilder *travelSegmentBuilder in self.travelSegmentBuilders) {
        [cellViewModels addObject:[self buildCellViewModelFromTravelSegmentBuilder:travelSegmentBuilder]];
    }
    return [cellViewModels copy];
}

- (ASTComplexSearchFormCellViewModel *)buildCellViewModelFromTravelSegmentBuilder:(JRSDKTravelSegmentBuilder *)travelSegmentBuilder {
    
    ASTComplexSearchFormCellViewModel *cellViewModel = [ASTComplexSearchFormCellViewModel new];
    
    cellViewModel.origin = [self buildCellSegmentViewModelFromAirport:travelSegmentBuilder.originAirport icon:@"origin_icon"];
    cellViewModel.destination = [self buildCellSegmentViewModelFromAirport:travelSegmentBuilder.destinationAirport icon:@"destination_icon"];
    cellViewModel.departure = [self buildCellSegmentViewModelFromDate:travelSegmentBuilder.departureDate icon:@"departure_icon"];
    
    return cellViewModel;
}

- (ASTComplexSearchFormCellSegmentViewModel *)buildCellSegmentViewModelFromAirport:(JRSDKAirport *)airport icon:(NSString *)icon {
    
    ASTComplexSearchFormCellSegmentViewModel *cellSegmentViewModel = [ASTComplexSearchFormCellSegmentViewModel new];
    
    cellSegmentViewModel.placeholder = airport == nil;
    cellSegmentViewModel.icon = icon;
    cellSegmentViewModel.title = airport.iata;
    cellSegmentViewModel.subtitle = airport == nil ? NSLS(@"JR_SEARCH_FORM_COMPLEX_PLACEHOLDER_AIRPORT_CELL_ACC") : airport.city;

    return cellSegmentViewModel;
}

- (ASTComplexSearchFormCellSegmentViewModel *)buildCellSegmentViewModelFromDate:(NSDate *)date icon:(NSString *)icon {
    
    ASTComplexSearchFormCellSegmentViewModel *cellSegmentViewModel = [ASTComplexSearchFormCellSegmentViewModel new];
    
    cellSegmentViewModel.placeholder = date == nil;
    cellSegmentViewModel.icon = icon;
    cellSegmentViewModel.title = [DateUtil dayMonthStringFromDate:date];
    cellSegmentViewModel.subtitle = date == nil ? NSLS(@"JR_SEARCH_FORM_COMPLEX_PLACEHOLDER_AIRPORT_CELL_ACC") : [DateUtil dateToYearString:date];
    
    return cellSegmentViewModel;
}

- (ASTComplexSearchFormFooterViewModel *)buildFooterViewModel {
    
    ASTComplexSearchFormFooterViewModel *viewModel = [ASTComplexSearchFormFooterViewModel new];
    
    viewModel.shouldEnableAdd = self.travelSegmentBuilders.count < maxTravelSegments;
    viewModel.shouldEnableRemove = self.travelSegmentBuilders.count > minTravelSegments;
    
    return viewModel;
}

- (ASTComplexSearchFormPassengersViewModel *)buildPassengersViewModel {
    
    ASTComplexSearchFormPassengersViewModel *viewModel = [ASTComplexSearchFormPassengersViewModel new];
    
    viewModel.adults = [NSString stringWithFormat:@"%@", @(self.searchInfoBuilder.adults)];
    viewModel.children = [NSString stringWithFormat:@"%@", @(self.searchInfoBuilder.children)];
    viewModel.infants = [NSString stringWithFormat:@"%@", @(self.searchInfoBuilder.infants)];
    viewModel.travelClass = [JRSearchInfoUtils travelClassStringWithTravelClass:self.searchInfoBuilder.travelClass];
    
    return viewModel;
}

#pragma mark - Restore & Create & Save

- (void)restoreSearchInfoBuilder {
    self.searchInfoBuilder = [[SearchInfoBuilderStorage shared] complexSearchInfoBuilder];
}

- (void)createTravelSegmentBuilders {
    NSMutableOrderedSet <JRSDKTravelSegmentBuilder *> *travelSegmentBuilders = [[NSMutableOrderedSet alloc] initWithCapacity:self.searchInfoBuilder.travelSegments.count];
    for (JRSDKTravelSegment *travelSegment in self.searchInfoBuilder.travelSegments) {
        [travelSegmentBuilders addObject:[[JRSDKTravelSegmentBuilder alloc] initWithTravelSegment:travelSegment]];
    }
    if (travelSegmentBuilders.count == 0) {
        [travelSegmentBuilders addObject:[JRSDKTravelSegmentBuilder new]];
    }
    self.travelSegmentBuilders = travelSegmentBuilders;
}

- (void)saveSearchInfoBuilder {
    [[SearchInfoBuilderStorage shared] setComplexSearchInfoBuilder:self.searchInfoBuilder];
}

#pragma mark - Logic

- (void)updateExpiredDepartureDates {

    NSDate *firstAvalibleForSearchDate = [DateUtil firstAvalibleForSearchDate];

    for (JRSDKTravelSegmentBuilder *travelSegmentBuilder in self.travelSegmentBuilders)  {
        if ([firstAvalibleForSearchDate compare:travelSegmentBuilder.departureDate] == NSOrderedDescending) {
            travelSegmentBuilder.departureDate = [DateUtil nextWeekend];
        }
    }
}

- (NSDate *)borderDateAtIndex:(NSInteger)index {
    NSDate *result = nil;
    if (self.travelSegmentBuilders.count > index && index > 0) {
        result = self.travelSegmentBuilders[index - 1].departureDate;
    }
    return result;
}

- (NSDate *)departureDateAtIndex:(NSInteger)index {
    NSDate *result = nil;
    if (self.travelSegmentBuilders.count > index) {
        result = self.travelSegmentBuilders[index].departureDate;
    }
    return result;
}

- (void)updateDatesFromIndex:(NSInteger)index withDate:(NSDate *)date {
    for (NSInteger i = index; i < self.travelSegmentBuilders.count; ++i) {
        JRSDKTravelSegmentBuilder *travelSegmentBuilder = self.travelSegmentBuilders[i];
        if (travelSegmentBuilder.departureDate &&  travelSegmentBuilder.departureDate < date) {
            travelSegmentBuilder.departureDate = date;
        }
    }
}

- (NSString *)validateTravelSegmentBuilders {
    NSString *result = nil;
    for (JRSDKTravelSegmentBuilder *travelSegmentBuilder in self.travelSegmentBuilders) {
        result = [self validateTravelSegmentBuilder:travelSegmentBuilder];
        if (result) {
            break;
        }
    }
    return result;
}

- (NSString *)validateTravelSegmentBuilder:(JRSDKTravelSegmentBuilder *)travelSegmentBuilder {

    JRSDKIATA originMainIATA = [[AviasalesSDK sharedInstance].airportsStorage mainIATAByIATA:travelSegmentBuilder.originAirport.iata];
    JRSDKIATA destinationMainIATA = [[AviasalesSDK sharedInstance].airportsStorage mainIATAByIATA:travelSegmentBuilder.destinationAirport.iata];

    NSString *result = nil;

    if (!travelSegmentBuilder.originAirport) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_ORIGIN_ERROR");
    } else if (!travelSegmentBuilder.destinationAirport) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_DESTINATION_ERROR");
    } else if ([originMainIATA isEqualToString:destinationMainIATA]) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_SAME_CITY_ERROR");
    } else if (!travelSegmentBuilder.departureDate) {
        result = NSLS(@"JR_SEARCH_FORM_AIRPORT_EMPTY_DEPARTURE_DATE");
    }

    return result;
}

- (void)buildTravelSegments {
    NSMutableArray <JRSDKTravelSegment *> *travelSegments = [[NSMutableArray alloc] initWithCapacity:self.travelSegmentBuilders.count];
    for (JRSDKTravelSegmentBuilder *travelSegmentBuilder in self.travelSegmentBuilders) {
        [travelSegments addObject:[travelSegmentBuilder build]];
    }
    self.searchInfoBuilder.travelSegments = [[NSOrderedSet alloc] initWithArray:travelSegments];
}

- (JRSDKSearchInfo *)buildSearchInfo {
    JRSDKSearchInfo *result = nil;
    NSString *error = [self validateTravelSegmentBuilders];
    if (error) {
        [self.viewController showErrorWithMessage:error];
    } else {
        [self buildTravelSegments];
        result = [self.searchInfoBuilder build];
    }
    return  result;
}

@end
