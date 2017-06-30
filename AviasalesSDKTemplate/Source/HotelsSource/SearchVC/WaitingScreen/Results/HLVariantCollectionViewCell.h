#import <UIKit/UIKit.h>
#import "HLTapGestureRecognizer.h"

@class HLVariantItem;
@class HLResultVariant;
@class HLProgressView;

typedef void (^CellSelectionBlock)(HLResultVariant *variant, NSUInteger index);

@interface HLVariantCollectionViewCell : UICollectionViewCell <UIGestureRecognizerDelegate, HLGestureRecognizerDelegate>

@property (nonatomic, strong, readonly) HLTapGestureRecognizer *tapRecognizer;
@property (nonatomic, strong, readonly) HLVariantItem *item;

@property (nonatomic, copy) CellSelectionBlock selectionHandler;

@property (nonatomic, assign) BOOL lazyLoadingContent;
@property (nonatomic, assign) BOOL badgesEnabled;

- (void)initialize;
- (void)resetContent;
- (void)setupWithItem:(HLVariantItem *)item;
- (void)drawBadges;

@end

@interface HLVariantCollectionViewCell (ScrollNotifications)

- (void)containerCollectionWillStartScroll;
- (void)containerCollectionDidStopScroll;

@end
