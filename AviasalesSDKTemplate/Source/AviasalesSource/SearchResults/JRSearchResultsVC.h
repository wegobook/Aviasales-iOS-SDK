//
//  JRSearchResultsVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRViewController.h"
#import "JRFilterVC.h"


@interface JRSearchResultsVC : JRViewController

- (instancetype)initWithSearchInfo:(JRSDKSearchInfo *)searchInfo response:(JRSDKSearchResult *)response;

@property (nonatomic, weak) IBOutlet UITableView *tableView;

@property (nonatomic, copy) void (^selectionBlock)(JRSDKTicket *selectedTicket);
@property (nonatomic, copy) void (^filterChangedBlock)(BOOL isEmptyResults);

@end
