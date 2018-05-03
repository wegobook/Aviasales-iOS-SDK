//
//  ASTSimpleSearchFormViewController.h
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import <UIKit/UIKit.h>
#import "ASTContainerSearchFormChildViewControllerProtocol.h"

@interface ASTSimpleSearchFormViewController : UIViewController <ASTContainerSearchFormChildViewControllerProtocol>

- (void)updateSearchInfoWithDestination:(JRSDKAirport *)destination checkIn:(NSDate *)checkIn checkOut:(NSDate *)checkOut passengers:(ASTPassengersInfo *)passengers;

- (void)update;

@end
