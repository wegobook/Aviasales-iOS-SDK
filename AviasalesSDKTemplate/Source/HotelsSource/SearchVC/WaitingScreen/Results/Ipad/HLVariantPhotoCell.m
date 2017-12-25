#import "HLVariantPhotoCell.h"
#import "UIImageView+WebCache.h"
#import "HLUrlUtils.h"

@interface HLVariantPhotoCell ()

@property (nonatomic, weak) IBOutlet UIImageView *bottomGradientView;
@property (nonatomic, weak) IBOutlet HLPhotoView *photoView;

@end

@implementation HLVariantPhotoCell

- (void)setupWithItem:(HLVariantItem *)item
{
    [super setupWithItem:item];

    UIImage *placeholder = [UIImage photoPlaceholder];

    if (self.item.variant.hotel.photosIds.count > 0) {
        NSURL *url = [HLUrlUtils firstHotelPhotoURLByHotel:self.item.variant.hotel withSizeInPoints:self.bounds.size];

        [self.photoView setImageWithUrl:url placeholder:placeholder animated:YES];
    } else {
        self.photoView.imageContentMode = UIViewContentModeCenter;
        [self.photoView setImage:placeholder needDelay:NO animated:YES];
    }
}

- (void)initialize
{
    [super initialize];
    
    self.photoView.imageContentMode = UIViewContentModeScaleAspectFill;
    self.photoView.placeholderContentMode = UIViewContentModeCenter;
}

-(void)resetContent
{
    [super resetContent];

    [self.photoView reset];
}

#pragma mark - HLGestureRecognizerDelegate methods

- (void)recognizerFinished
{
    [super recognizerFinished];
    
    self.selectionHandler(self.item.variant, 0);
}

@end
