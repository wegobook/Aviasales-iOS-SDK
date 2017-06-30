#import <Foundation/Foundation.h>

@protocol HLFilteringOperationDelegate <NSObject>

- (void)variantsFiltered:(NSArray *)filteredVariants withoutPriceFilter:(NSArray *)filteredVariantsWithoutPriceFilter;

@end


@class Filter;

@interface HLFilteringOperation : NSOperation

@property (nonatomic, strong) NSArray *variants;

@property (nonatomic, weak) Filter *filter;
@property (nonatomic, weak) id<HLFilteringOperationDelegate> delegate;

@end
