#import "HLMapGroupDetailsVC.h"
#import "HLMapGroupDetailsCell.h"
#import "HLVariantsSorter.h"

@interface HLMapGroupDetailsVC () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, weak) IBOutlet UILabel *countLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint * collectionViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * collectionViewHeightConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint * descriptionBottomConstraint;

@property (nonatomic, assign) NSInteger selectedIndex;
@property (nonatomic, assign) CGFloat itemsSpacing;
@property (nonatomic, assign) BOOL shouldUpdateSelectedIndexOnScrollViewDidScroll;

@property (nonatomic, strong) HLHotelDetailsDecorator *hotelDetailsDecorator;

@end

@implementation HLMapGroupDetailsVC

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor blackColor];

    self.shouldUpdateSelectedIndexOnScrollViewDidScroll = YES;
    self.itemsSpacing = 20.0;
    self.automaticallyAdjustsScrollViewInsets = NO;

    UICollectionViewFlowLayout *collectionLayout = [UICollectionViewFlowLayout new];
    collectionLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    collectionLayout.minimumInteritemSpacing = self.itemsSpacing;
    collectionLayout.minimumLineSpacing = 20.0f;
    self.collectionView.collectionViewLayout = collectionLayout;
    [self.collectionView registerClass:[HLMapGroupDetailsCell class] forCellWithReuseIdentifier:@"HLMapGroupDetailsCell"];
    self.collectionView.scrollsToTop = NO;
    
    self.collectionViewHeightConstraint.constant = [self cellHeight];
    self.collectionViewTopConstraint.constant = [self collectionViewTopConstant];
    
    [self updateCountLabelWithIndex:0];
    [self setupDescriptionLabel];
    
    self.descriptionBottomConstraint.constant = [self descriptionBottomConstant];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self updateVisibleCellsWithContentOffset:0.0];
    self.hotelDetailsDecorator = nil;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.collectionViewTopConstraint.constant = [self collectionViewTopConstant];
    [self.collectionView setNeedsLayout];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    self.shouldUpdateSelectedIndexOnScrollViewDidScroll = NO;

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [self.collectionView.collectionViewLayout invalidateLayout];
    self.selectedIndex = [self visibleIndexForOffset:self.collectionView.contentOffset];

    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        CGFloat newX = (self.selectedIndex) * ([self cellWidth] + self.itemsSpacing);
        self.collectionView.contentOffset = CGPointMake(newX, 0.0);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.shouldUpdateSelectedIndexOnScrollViewDidScroll = YES;
        [self updateSelectionViewWithIndex:self.selectedIndex];
    }];
}

- (void)setupDescriptionLabel
{
    if (iPhone35Inch()) {
        self.descriptionLabel.text = NSLS(@"HL_LOC_MAP_GROUP_DESCRIPTION_SHORT");
        self.descriptionLabel.numberOfLines = 1;
    } else {
        self.descriptionLabel.text = NSLS(@"HL_LOC_MAP_GROUP_DESCRIPTION_LONG");
        self.descriptionLabel.numberOfLines = 0;
    }
}

- (void)updateCountLabelWithIndex:(NSInteger)index
{
    self.countLabel.text = [NSString stringWithFormat:@"%i %@ %li", (int)(index + 1), NSLS(@"HL_LOC_FROM_CONJUCTION"), (unsigned long)self.variants.count];
}

- (void)setVariants:(NSArray *)variants
{
    _variants = [VariantsSorter sortVariantsByPrice:variants];
}

#pragma mark - Device-related constraints

- (CGFloat)cellWidth
{
    return iPhone() ? 270.0 : 385.0;
}

- (CGFloat)cellHeight
{
    return iPhone() ? 171.0 : 240.0;
}

- (CGFloat)collectionViewTopConstant
{
    if (iPad()) {
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        return UIInterfaceOrientationIsLandscape(orientation) ? 180.0 : 300.0;
    }
    
    if (iPhone35Inch()) {
        return 82.0;
    } else if (iPhone4Inch()) {
        return 150.0;
    } else if (iPhone47Inch()) {
        return 150.0;
    } else {
        return 180.0;
    }
}

- (CGFloat)descriptionBottomConstant
{
    if (iPhone35Inch() || iPhone4Inch()) {
        return 20.0;
    }
    
    return 40.0;
}

- (CGFloat)horizontalSideOffset
{
    return (self.collectionView.frame.size.width - self.cellWidth) / 2.0;
}

#pragma mark - UICollectionViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.variants.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HLMapGroupDetailsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HLMapGroupDetailsCell" forIndexPath:indexPath];
    cell.variant = self.variants[indexPath.row];
    cell.layer.cornerRadius = 5.0;
    cell.clipsToBounds = YES;
    cell.backgroundColor = [UIColor whiteColor];
    cell.delegate = self;
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(self.cellWidth, self.cellHeight);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    return CGSizeMake([self horizontalSideOffset], [self collectionViewTopConstant]);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section
{
    return CGSizeMake([self horizontalSideOffset], 0.0);
}

#pragma mark - UIScrollViewDelegate Methods

- (NSInteger)visibleIndexForOffset:(CGPoint)offset
{
    CGFloat offsetX = offset.x;
    CGSize itemSize = [self collectionView:self.collectionView layout:self.collectionView.collectionViewLayout sizeForItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    NSInteger index = (NSInteger)(offsetX / (itemSize.width + self.itemsSpacing) + 0.5);
    index = MIN(MAX(0, index), self.variants.count - 1);
    
    return index;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (!self.shouldUpdateSelectedIndexOnScrollViewDidScroll) {
        return;
    }
    NSInteger index = [self visibleIndexForOffset:scrollView.contentOffset];
    
    [self updateSelectionViewWithIndex:index];
    [self updateVisibleCellsWithContentOffset:scrollView.contentOffset.x];
}

- (void)updateVisibleCellsWithContentOffset:(CGFloat)offset
{
    for (NSIndexPath *path in self.collectionView.indexPathsForVisibleItems) {
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:path];
        cell.alpha = [self alphaForCellAtIndexPath:path withOffset:offset];
    }
}

- (CGFloat)alphaForCellAtIndexPath:(NSIndexPath *)path withOffset:(CGFloat)offset
{
    UICollectionViewLayoutAttributes *attr = [self.collectionView layoutAttributesForItemAtIndexPath:path];
    CGFloat offsetX = attr.frame.origin.x;
    offsetX = offsetX - offset;
    CGFloat alpha = 1.0;
    if (offsetX < [self horizontalSideOffset]) {
        alpha = 0.4 + MAX(0.6 * (offsetX + self.cellWidth) / self.cellWidth, 0.0);
    } else {
        alpha = 0.4 + MAX(0.6 * (self.collectionView.frame.size.width - offsetX) / self.cellWidth, 0.0);
    }
    
    return alpha;
}

- (void)updateSelectionViewWithIndex:(NSInteger)index
{
    self.selectedIndex = index;
    [self updateCountLabelWithIndex:index];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat targetX = targetContentOffset->x;
    NSInteger index = [self visibleIndexForOffset:CGPointMake(targetX, 0.0)];
    
    if (velocity.x > 0) {
        index += 1;
    } else if (velocity.x < 0) {
        index -= 1;
    }
    
    index = MIN(MAX(0, index), self.variants.count - 1);
    
    CGFloat newX = (index) * (self.cellWidth + self.itemsSpacing);
    targetContentOffset->x = newX;
}

#pragma mark - HLShowHotelProtocol Methods

- (void)showFullHotelInfo:(HLResultVariant *)variant visiblePhotoIndex:(NSInteger)visiblePhotoIndex indexChangedBlock:(void (^)(NSInteger index))block peeked:(BOOL)peeked
{
    [self.delegate showFullHotelInfo:variant visiblePhotoIndex:visiblePhotoIndex indexChangedBlock:(void (^)(NSInteger index))block peeked:peeked];
}

@end
