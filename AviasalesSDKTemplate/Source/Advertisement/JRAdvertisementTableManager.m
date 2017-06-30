//
//  JRAdvertisementTableManager.m
//
//  Copyright 2016 Go Travel Un Limited
//  This code is distributed under the terms and conditions of the MIT license.
//

#import "JRAdvertisementTableManager.h"
#import "JRHotelCardView.h"

static NSString *const kCellReusableId = @"JRAdvertisementTableManagerAdCell";
static const NSInteger kAdViewTag = 567134;
static const CGFloat kAviasalesAdHeight = 130;
static const CGFloat kHotelCardHeight = 155;

@implementation JRAdvertisementTableManager

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSInteger count = 0;
    if (self.aviasalesAd != nil) {
        ++count;
    }

    if (self.hotelCard != nil) {
        ++count;
    }
    return count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UIView *adView;
    if (indexPath.section == 0 && self.aviasalesAd != nil) {
        adView = self.aviasalesAd;
    } else {
        adView = self.hotelCard;
    }
    UITableViewCell *res = [tableView dequeueReusableCellWithIdentifier:kCellReusableId];

    if (res == nil) {
        res = [[UITableViewCell alloc] init];
    } else {
        [[res.contentView viewWithTag:kAdViewTag] removeFromSuperview];
    }

    [adView removeFromSuperview];
    adView.frame = res.contentView.bounds;
    adView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [res.contentView addSubview:adView];
    return res;
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 && self.aviasalesAd != nil) {
        return kAviasalesAdHeight;
    } else {
        return kHotelCardHeight;
    }
}

@end
