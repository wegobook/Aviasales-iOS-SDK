#import "HLVariantScrollablePhotoCell.h"
#import "HLResultVariant.h"

@interface HLVariantScrollablePhotoCell () <HLPhotoScrollViewDelegate>

@property (nonatomic, weak) IBOutlet HLPhotoScrollView *photoScrollView;

@end


@implementation HLVariantScrollablePhotoCell

#pragma mark - Public methods

- (void)resetContent
{
    HLPhotoScrollCollectionCell *visibleCell = (HLPhotoScrollCollectionCell *)self.photoScrollView.visibleCell;
    if ([visibleCell isKindOfClass:[HLPhotoScrollCollectionCell class]]) {
        [visibleCell.photoView reset];
    }
    [self.photoScrollView.collectionView.collectionViewLayout invalidateLayout];
}

- (BOOL)scrollEnabled
{
    return self.photoScrollView.collectionView.scrollEnabled;
}

- (void)setScrollEnabled:(BOOL)scrollEnabled
{
    self.photoScrollView.collectionView.scrollEnabled = scrollEnabled;
}

- (void)setupWithItem:(HLVariantItem *)item
{
    [super setupWithItem:item];
    
    [self updatePhotosContent];
    self.visiblePhotoIndex = item.photoIndex;
}

- (NSInteger)visiblePhotoIndex
{
    return self.photoScrollView.currentPhotoIndex;
}

- (void)setVisiblePhotoIndex:(NSInteger)index
{
    [self.photoScrollView scrollToPhotoIndex:index animated:NO];
}

- (void)containerCollectionWillStartScroll
{
    [super containerCollectionWillStartScroll];
    
    self.photoScrollView.userInteractionEnabled = NO;
}

- (void)containerCollectionDidStopScroll
{
    [super containerCollectionDidStopScroll];
    
    self.photoScrollView.userInteractionEnabled = YES;
}

- (void)initialize
{
    [super initialize];
    
    self.photoScrollView.placeholderImage = [UIImage photoPlaceholder];
}

#pragma mark - Private methods 

- (void)updatePhotosContent
{
    self.photoScrollView.delegate = self;
    self.photoScrollView.backgroundColor = [JRColorScheme hotelBackgroundColor];
    [self.photoScrollView updateDataSourceWithHotel:self.item.variant.hotel imageSize:self.bounds.size firstImage:nil];
    [self.photoScrollView relayoutContent];
}

#pragma mark - UIGestureRecognizerDelegate methods

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.photoScrollView.collectionView.isDecelerating || self.photoScrollView.collectionView.isDragging) {
        return NO;
    }

    return [super gestureRecognizerShouldBegin:gestureRecognizer];
}

#pragma mark - HLGestureRecognizerDelegate methods

- (void)recognizerFinished
{
    [super recognizerFinished];

    if (self.selectionHandler != nil) {
        self.selectionHandler(self.item.variant, self.visiblePhotoIndex);
    }
}

#pragma mark - HLPhotoCollectionViewDelegate methods

- (UIViewContentMode)photoCollectionViewImageContentMode
{
    return (self.item.variant.hotel.photosIds.count == 0) ? UIViewContentModeCenter : UIViewContentModeScaleAspectFill;
}

@end

