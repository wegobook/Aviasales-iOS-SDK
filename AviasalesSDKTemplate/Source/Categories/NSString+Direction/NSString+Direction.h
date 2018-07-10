//
//  NSString+Direction.h
//  Aviasales iOS Apps
//
//  Created by Dmitry Ryumin on 24/10/2016.
//  Copyright © 2016 aviasales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Direction)

- (NSString *)rtlStringIfNeeded;

- (NSString *)formatAccordingToTextDirection;

@end
