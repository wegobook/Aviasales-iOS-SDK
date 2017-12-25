#import "HLSingleAnnotationView.h"
#import <PureLayout/PureLayout.h>
#import "StringUtils.h"
#import "HLResultVariant.h"

#define HL_CALLOUT_ANIMATION_DURATION 0.2f

static CGRect TBCenterRect(CGRect rect, CGPoint center)
{
    return CGRectMake(center.x - rect.size.width/2.0,
                      center.y - rect.size.height/2.0,
                      rect.size.width,
                      rect.size.height);
}

static const CGPoint kCollapsedCenterOffset = {0.0f, 0.0f};
static const CGFloat kPriceLabelHorizontalPadding = 5.0;
static const CGFloat kTopShadowHeight = 2.0;
static const CGFloat kBottomShadowHeight = 7.0;
static const CGFloat kRightShadowWidth = 2.0;
static const CGFloat kAnnotationViewHeight = 24 + kTopShadowHeight + kBottomShadowHeight;

@interface HLSingleAnnotationView ()
@property (strong, nonatomic) UIImage *leftImage;
@property (strong, nonatomic) UIImage *rightImage;
@property (strong, nonatomic) RatingView *ratingView;
@property (nonatomic, strong) HLVariantScrollablePhotoCell *variantView;
@property (nonatomic, strong) HotelInfoViewLogic *infoViewLogic;

@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) UIImageView *rightImageView;

@property (nonatomic, strong) NSLayoutConstraint *ratingWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *priceLeadingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *priceTrailingConstraint;
@property (nonatomic, strong) NSLayoutConstraint *priceVerticalConstraint;

@property (nonatomic, assign, readwrite) UIEdgeInsets extraInsets;

@end

@implementation HLSingleAnnotationView

#pragma mark - Override

- (void)initialSetup
{
    if (@available(iOS 11.0, *)) {
        self.extraInsets = UIEdgeInsetsMake(5, 5, 5, 5);
    } else {
        self.extraInsets = UIEdgeInsetsZero;
    }
    self.leftImage = [UIImage imageNamed:@"pinImageLeft.png"];
    self.rightImage = [UIImage imageNamed:@"pinImageRight.png"];
    self.infoViewLogic = [HotelInfoViewLogic new];

    [super initialSetup];

    [self addRatingView];

    self.priceLabel.textColor = [JRColorScheme darkTextColor];
    self.clipsToBounds = YES;
    self.centerOffset = kCollapsedCenterOffset;

    [self setupConstraints];
}

- (void)addBackgroundView
{
    self.backgroundView = [UIView new];
    [self addSubview:self.backgroundView];
    self.backgroundView.translatesAutoresizingMaskIntoConstraints = NO;

    self.leftImageView = [UIImageView new];
    UIImage *leftPinImage = [self.leftImage resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 4.0, 10.0, 5.0) resizingMode:UIImageResizingModeStretch];
    self.leftImageView.image = leftPinImage;

    self.rightImageView = [UIImageView new];
    UIImage *rightPinImage = [self.rightImage resizableImageWithCapInsets:UIEdgeInsetsMake(4.0, 5.0, 10.0, 4.0) resizingMode:UIImageResizingModeStretch];
    self.rightImageView.image = rightPinImage;

    [self.backgroundView addSubview:self.leftImageView];
    [self.backgroundView addSubview:self.rightImageView];
}

- (void)addRatingView
{
    self.ratingView = [RatingView new];
    [self.backgroundView addSubview:self.ratingView];
}

- (void)setVariants:(NSArray *)variants
{
    [super setVariants:variants];

    [self.ratingView setupWithHotel:self.variant.hotel];
    [self updateContentAndCollapseIfExpanded];
}

#pragma mark - Layout

- (void)setupConstraints
{
    [self.backgroundView autoPinEdgesToSuperviewEdgesWithInsets:self.extraInsets];

    [self.leftImageView autoMatchDimension:ALDimensionWidth toDimension:ALDimensionWidth ofView:self.rightImageView];

    [self.leftImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.leftImageView autoPinEdgeToSuperviewEdge:ALEdgeLeading];
    [self.leftImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.leftImageView autoPinEdge:ALEdgeTrailing toEdge:ALEdgeLeading ofView:self.rightImageView];

    [self.rightImageView autoPinEdgeToSuperviewEdge:ALEdgeTrailing];
    [self.rightImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.rightImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];

    [self.ratingView autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:kTopShadowHeight];
    [self.ratingView autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:kBottomShadowHeight];
    [self.ratingView autoPinEdgeToSuperviewEdge:ALEdgeLeading withInset:0.0];
    self.ratingWidthConstraint = [self.ratingView autoSetDimension:ALDimensionWidth toSize:[self ratingViewWidth]];

    self.priceLeadingConstraint = [self.priceLabel autoPinEdge:ALEdgeLeading toEdge:ALEdgeTrailing ofView:self.ratingView withOffset:[self priceLeading]];
    self.priceTrailingConstraint = [self.priceLabel autoPinEdgeToSuperviewEdge:ALEdgeTrailing withInset:[self priceTrailing]];
    [self.priceLabel autoAlignAxis:ALAxisHorizontal toSameAxisOfView:self.priceLabel.superview withOffset:-3.0];
}

- (void)recalculateConstraints
{
    self.ratingWidthConstraint.constant = [self ratingViewWidth];
    self.priceLeadingConstraint.constant = [self priceLeading];
    self.priceTrailingConstraint.constant = -[self priceTrailing];
    self.priceVerticalConstraint.constant = [self hasPrice] ? 0 : -1;
}

- (void)recalculateViewSize
{
    CGSize size = [self systemLayoutSizeFittingSize:CGSizeMake(CGFLOAT_MAX, kAnnotationViewHeight)
                      withHorizontalFittingPriority:UILayoutPriorityFittingSizeLevel
                            verticalFittingPriority:UILayoutPriorityRequired];

    CGRect frame = CGRectMake(0.0, 0.0, size.width, size.height + self.extraInsets.top + self.extraInsets.bottom);
    frame = TBCenterRect(frame, self.center);
    self.frame = frame;
}

- (CGFloat)ratingViewWidth
{
    return [self showsRatingView] ? 26.0 : 0.0;
}

- (CGFloat)priceLeading
{
    if ([self showsRatingView]) {
        return kPriceLabelHorizontalPadding + [self additionalWidthForNoPrice];
    } else {
        return kPriceLabelHorizontalPadding + kRightShadowWidth + [self additionalWidthForNoPrice];
    }
}

- (CGFloat)priceTrailing
{
    return kPriceLabelHorizontalPadding + kRightShadowWidth + [self additionalWidthForNoPrice];
}

- (CGFloat)additionalWidthForNoPrice
{
    return [self hasPrice] ? 0 : 1;
}

- (BOOL)showsRatingView
{
    return self.variant.hotel.rating > 0 && self.variant.filteredRooms.count > 0;
}

#pragma mark - Private

+ (CGSize)calloutSize
{
    CGFloat width = iPhone() ? 285.0 : 385.0;

    return CGSizeMake(width, [self calloutHeight]);
}

- (void)hidePinContent
{
	self.priceLabel.alpha = 0.0;
    self.ratingView.alpha = 0.0;
}

- (void)showPinContent
{
	self.priceLabel.alpha = 1.0;
    self.ratingView.alpha = 1.0;
}

- (void)addCalloutContent
{
    CGSize size = [HLSingleAnnotationView calloutSize];
    self.frame = CGRectMake(0.0, 0.0, size.width, size.height);
    self.centerOffset = CGPointMake(0.0, -size.height / 2.0 + kAnnotationViewHeight / 2.0);

    if (![self.backgroundView.subviews containsObject:self.variantView]) {
        [self.backgroundView addSubview:self.variantView];
    }

    [self.variantView autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsMake(5, 5, 10, 5)];
    [self layoutIfNeeded];

    HLVariantItem *variantItem = [[HLVariantItem alloc] initWithVariant:[self variant]];
    [self.variantView setupWithItem:variantItem];
}

- (void)removeCalloutContent
{
    self.centerOffset = kCollapsedCenterOffset;
    [self updateContent];
}

- (void)showCalloutContent
{
	self.variantView.alpha = 1.0;
}

- (void)hideCalloutContent
{
	self.variantView.alpha = 0.0;
}

- (BOOL)isExpanded
{
    return self.variantView.superview != nil;
}

- (HLResultVariant *)variant
{
    return self.variants.lastObject;
}

- (void)configurePriceLabel
{
    NSAttributedString *priceString = [StringUtils attributedPriceStringWithVariant:self.variant
                                                                           currency:self.variant.searchInfo.currency
                                                                               font:self.priceLabel.font
                                                                       noPriceColor:[UIColor blackColor]];
    self.priceLabel.attributedText = priceString;
}

- (BOOL)hasPrice
{
    return self.variant.rooms.count > 0;
}

#pragma mark - Public

+ (CGFloat)calloutHeight
{
    return iPhone() ? 180.0 : 240.0;
}

- (void)updateContentAndCollapseIfExpanded
{
    if ([self isExpanded]) {
        [self collapseAnimated:NO];
    }

    [self updateContent];
}

- (void)updateContent
{
    [self configurePriceLabel];
    [self recalculateConstraints];
    [self recalculateViewSize];
}

- (void)expandAnimated:(BOOL)animated
{
    if (self.variantView == nil) {
        self.variantView = LOAD_VIEW_FROM_NIB_NAMED(@"HLVariantScrollablePhotoCell");
        self.variantView.translatesAutoresizingMaskIntoConstraints = NO;
        self.variantView.alpha = 0.0;

        @weakify(self)
        self.variantView.selectionHandler = ^(HLResultVariant *variant, NSUInteger index) {
            @strongify(self)
            [self.delegate showFullHotelInfo:variant
                           visiblePhotoIndex:index
                           indexChangedBlock:^(NSInteger index) { self.variantView.visiblePhotoIndex = index; }
                                      peeked:NO];
        };
    }

    UIViewAnimationOptions options = UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
	CGFloat duration = animated ? HL_CALLOUT_ANIMATION_DURATION : 0.0;
	[UIView animateWithDuration:duration
						  delay:0.0
						options:options
					 animations:^{ [self hidePinContent]; }
					 completion:^(BOOL finished) {
                         [self.backgroundView addSubview:self.variantView];
                         [UIView animateWithDuration:duration
                                               delay:0.0
                                             options:options
                                          animations:^{ [self addCalloutContent]; }
                                          completion:^(BOOL finished) {
                                              if ([self.backgroundView.subviews containsObject:self.variantView]) {
                                                  [UIView animateWithDuration:duration
                                                                        delay:0.0
                                                                      options:options
                                                                   animations:^{ [self showCalloutContent]; }
                                                                   completion:nil];
                                              } else {
                                                  [self collapseAnimated:animated];
                                              }
                                          }];
					 }];
}

- (void)collapseAnimated:(BOOL)animated
{
    UIViewAnimationOptions options = UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionLayoutSubviews | UIViewAnimationOptionBeginFromCurrentState;
	CGFloat duration = animated ? HL_CALLOUT_ANIMATION_DURATION : 0.0;
	[UIView animateWithDuration:duration
						  delay:0.0
						options:options
					 animations:^{ [self hideCalloutContent]; }
					 completion:^(BOOL finished) {
                         [self.variantView removeFromSuperview];
                         [UIView animateWithDuration:duration
                                               delay:0.0
                                             options:options
                                          animations:^{ [self removeCalloutContent]; }
                                          completion:^(BOOL finished) {
                                              [UIView animateWithDuration:duration
                                                                    delay:0.0
                                                                  options:options
                                                               animations:^{ [self showPinContent]; }
                                                               completion:nil];
                                          }];
					 }];
}

- (CGRect)photoRect
{
    return self.variantView.frame;
}

@end
