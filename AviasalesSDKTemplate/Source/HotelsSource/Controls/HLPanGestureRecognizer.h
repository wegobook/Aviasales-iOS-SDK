//
//  HLPanGestureRecognizer.h
//  HotelLook
//
//  Created by Oleg on 27/05/14.
//  Copyright (c) 2014 Anton Chebotov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIGestureRecognizerSubclass.h>


typedef enum {
    HLPanGestureRecognizerDirectionVertical,
    HLPanGestureRecognizerDirectionHorizontal
} HLPanGestureRecognizerDirection;


@interface HLPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) HLPanGestureRecognizerDirection direction;

@end

