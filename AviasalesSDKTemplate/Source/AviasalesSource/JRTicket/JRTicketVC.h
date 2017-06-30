//
//  JRTicketVC.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "JRViewController.h"

@interface JRTicketVC : JRViewController

@property (nonatomic, weak) IBOutlet UITableView *tableView;

- (instancetype)initWithSearchInfo:(JRSDKSearchInfo *)searchInfo searchID:(NSString *)searchID;

- (void)setTicket:(JRSDKTicket *)ticket;

@end
