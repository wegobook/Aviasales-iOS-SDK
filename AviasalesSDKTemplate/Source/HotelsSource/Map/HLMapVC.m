#import "HLMapVC.h"

#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"
#import "HLNearbyCitiesDetector.h"
#import "HLGroupAnnotationView.h"
#import "HLPoiIconSelector.h"
#import "HLSingleAnnotationView.h"
#import "NSArray+Functional.h"
#import "HDKCity+Hotellook.h"

#define HL_MAP_CALLOUT_ANIMATION_DURATION 0.2f

static NSString *const HLSingleAnnotationViewReuseID = @"singleAnnotationView";
static NSString *const HLGroupAnnotationViewReuseID = @"groupAnnotationView";

@interface HLMapVC () <HLNearbyCitiesDetectionDelegate, UIViewControllerPreviewingDelegate, PeekHotelVCDelegate, HLLocateMeMapViewDelegate>

@property (nonatomic, strong) NSArray *variants;
@property (nonatomic, strong) HLResultVariant *peekedVariant;
@property (nonatomic, strong) HLSingleAnnotationView *expandedAnnotation;
@property (nonatomic, assign) BOOL shouldAnimateFiltersOnViewDidAppear;
@property (nonatomic, assign) BOOL didSetInitialRegion;
@property (nonatomic, strong) NSArray<PoiAnnotation *> *poiAnnotations;
@property (nonatomic, weak) IBOutlet HLLocateMeMapView *locateMeMapView;
@property (nonatomic, strong) NSDate *didSelectTime;
@property (nonatomic, assign) BOOL canCloseSelectedAnnotation;

@end

@implementation HLMapVC

- (void)viewDidLoad
{
	[super viewDidLoad];
    self.canCloseSelectedAnnotation = YES;

    [self addSearchInfoView:self.searchInfo];
    
    self.clusteringEnabled = YES;

    self.locateMeMapView.delegate = self;
    UITapGestureRecognizer *tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deselectAnnotation)];
    tapRec.delaysTouchesBegan = NO;
    [self.mapView addGestureRecognizer:tapRec];
    self.mapView.gestureRecognizerDelegate = self;

    [[HLLocationManager sharedManager] hasUserGrantedLocationAccessOnCompletion:^(BOOL accessGranted) {
        self.mapView.showsUserLocation = accessGranted;
    }];

    [self registerForCurrentCityNotifications];
    [self registerForPreviewingWithDelegate:self sourceView:self.view];
    [self setupFilterButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self resetPoiAnnotations];
    if (!self.didSetInitialRegion) {
        self.clusteringEnabled = NO;
        [self.view layoutIfNeeded];
        self.clusteringEnabled = YES;
        [self showInitialRegionForVariants:self.variants];
        self.didSetInitialRegion = YES;
    }
}

- (void)dealloc
{
    [self unregisterNotificationResponse];
}

- (void)setupFilterButton
{
    [self.filtersButton setTitle:NSLS(@"HL_FILTER_BUTTON_TITLE_LABEL") forState:UIControlStateNormal];
    UIImage *markImage = [UIImage imageNamed:@"filtersButtonActive"];
    [self.filtersButton setImage:markImage forState:UIControlStateSelected];
    [self.filtersButton setImage:markImage forState:UIControlStateHighlighted | UIControlStateSelected];
}

- (void)deselectAnnotation
{
    [self.mapView deselectAnnotation:self.expandedAnnotation.annotation animated:NO];
    [self.expandedAnnotation collapseAnimated:YES];
    self.expandedAnnotation = nil;
}

#pragma mark - HLLocateMeMapViewDelegate

-(void)locateMeMapView:(HLLocateMeMapView *)locateMeMapView shouldShowUserLocation:(CLLocation *)userLocation
{
    self.mapView.showsUserLocation = YES;
    [self locateMeAction];
}

#pragma mark - Private

- (void)resetPoiAnnotations
{
    if (self.poiAnnotations.count > 0) {
        [self.mapView removeAnnotations:self.poiAnnotations];
        for (PoiAnnotation *annotation in self.poiAnnotations) {
            [self.ungroupableAnnotations removeObject:annotation];
        }
        self.poiAnnotations = nil;
    }

    self.poiAnnotations = [self createPoiAnnotations];
    [self.mapView addAnnotations:self.poiAnnotations];
    [self.ungroupableAnnotations addObjectsFromArray:self.poiAnnotations];
}

- (NSArray<PoiAnnotation *> *)createPoiAnnotations
{
    NSMutableArray *annotations = [NSMutableArray new];
    HDKLocationPoint *filterSelectedPoint = self.filter.distanceLocationPoint;
    if (![filterSelectedPoint isKindOfClass:[HLGenericCategoryLocationPoint class]]) {
        PoiAnnotation *filterSelectedAnnotation = [[PoiAnnotation alloc] init:filterSelectedPoint];
        [annotations addObject:filterSelectedAnnotation];
    }

    NSArray<PoiAnnotation *> *airportAnnotations = [[self.searchInfo.cityByCurrentSearchType airports] map: ^PoiAnnotation *(HDKLocationPoint *point) {
        return [[PoiAnnotation alloc] init:point];
    }];
    if (airportAnnotations.count > 0) {
        [annotations addObjectsFromArray:airportAnnotations];
    }

    return [annotations copy];
}

- (void)showMapGroupContents:(NSArray *)variants
{
    HLMapGroupDetailsVC *detailsVC = [[HLMapGroupDetailsVC alloc] initWithNibName:@"HLMapGroupDetailsVC" bundle:nil];
    detailsVC.variants = variants;
    detailsVC.delegate = self;

    [self.navigationController pushViewController:detailsVC animated:YES];    
}

- (void)showInitialRegionForVariants:(NSArray *)variants
{
    if (variants.count == 0) {
        [self.mapView showCity:self.searchInfo.city ?: self.searchInfo.locationPoint.nearbyCities.firstObject];
    } else {
        [self.mapView setRegionForVariants:variants insets:[self mapEdgeInsets] animated:NO];
    }
}

- (void)expandSingleAnotationView:(HLSingleAnnotationView *)view
{
    [view expandAnimated:YES];
    
    self.expandedAnnotation.layer.zPosition = HL_POI_ANNOTATION_ZPOSITION;
    self.expandedAnnotation = view;
    self.expandedAnnotation.layer.zPosition = HL_SELECTED_ANNOTATION_ZPOSITION;
    [self.mapView bringSubviewToFront:self.expandedAnnotation];
}

- (MKAnnotationView *)singleVariantAnnotationView:(TBClusterAnnotation *)annotation mapView:(MKMapView *)mapView
{
    HLSingleAnnotationView *annotationView = (HLSingleAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:HLSingleAnnotationViewReuseID];
    if (!annotationView) {
        annotationView = [[HLSingleAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:HLSingleAnnotationViewReuseID];
        annotationView.delegate = self;
    }
    annotationView.variants = annotation.variants;

    return annotationView;
}

- (MKAnnotationView *)groupAnnotationView:(TBClusterAnnotation *)annotation mapView:(MKMapView *)mapView
{
    HLGroupAnnotationView *annotationView = (HLGroupAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:HLGroupAnnotationViewReuseID];
    if (!annotationView) {
        annotationView = [[HLGroupAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:HLGroupAnnotationViewReuseID];
    }
    annotationView.variants = annotation.variants;

    return annotationView;
}

- (BOOL)shouldCloseSelectedAnnotation
{
    return self.canCloseSelectedAnnotation && [[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground;
}

- (BOOL)expandedAnnotationContains:(HLResultVariant *)variant
{
    return self.expandedAnnotation.variants.firstObject == variant;
}

- (UIEdgeInsets)mapEdgeInsets
{
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

#pragma mark - UIViewControllerPreviewingDelegate

- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location NS_AVAILABLE_IOS(9_0)
{
    CGPoint locationOnMap = [self.mapView convertPoint:location fromView:self.view];
    HLSingleAnnotationView *annotationView = [self annotationAtPoint:locationOnMap];
    self.peekedVariant = annotationView.variants.firstObject;
    if (self.peekedVariant) {
        if ([self expandedAnnotationContains:self.peekedVariant]) {
            previewingContext.sourceRect = [self.view convertRect:annotationView.photoRect fromView:annotationView];
        } else {
            previewingContext.sourceRect = CGRectMake(location.x, location.y, 1.0, 1.0);
        }
        return [self createPeekHotelVC:self.peekedVariant filter:self.filter];
    }

    return nil;
}

- (void)previewingContext:(id <UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit NS_AVAILABLE_IOS(9_0)
{
    [self showPeekDetails];
}

- (HLSingleAnnotationView *)annotationAtPoint:(CGPoint)point
{
    for (id <MKAnnotation> ann in self.mapView.annotations) {
        MKAnnotationView *annView = [self.mapView viewForAnnotation:ann];
        if ([annView isKindOfClass:[HLSingleAnnotationView class]] && CGRectContainsPoint(annView.frame, point)) {
            return (HLSingleAnnotationView *)annView;
        }
    }

    return nil;
}

- (PeekHotelVC *)createPeekHotelVC:(HLResultVariant *)variant filter:(Filter *)filter
{
    PeekHotelVC *peekVC = [[PeekHotelVC alloc] initWithNibName:@"PeekTableVC" bundle:nil];
    peekVC.shouldAddMapCell = [self expandedAnnotationContains:self.peekedVariant];
    peekVC.variant = variant;
    peekVC.filter = self.filter;
    CGFloat peekWidth = [UIScreen mainScreen].bounds.size.width;
    peekVC.preferredContentSize = CGSizeMake(peekWidth, [peekVC heightForVariant:self.peekedVariant peekWidth:peekWidth]);
    peekVC.viewControllerToShowBrowser = self;
    peekVC.delegate = self;

    return peekVC;
}

#pragma mark - Actions

- (IBAction)locateMeAction
{
    HDKCity *currentCity = [HLNearbyCitiesDetector shared].nearbyCities.firstObject;
    HDKCity *searchInfoCity = self.searchInfo.city ?: self.searchInfo.locationPoint.city ?: self.searchInfo.locationPoint.nearbyCities.firstObject;

    if (currentCity == nil) {
        [[HLLocationManager sharedManager] requestUserLocationWithLocationDestination:kShowCurrentLocationOnMap];
    } else if (searchInfoCity && ![searchInfoCity isEqual:currentCity]) {
        [self.mapView setRegionForUserAndTheCity:searchInfoCity];
        self.locateMeMapView.locateMeButton.selected = YES;
    } else {
        [self.mapView setRegionForUserLocation];
        self.locateMeMapView.locateMeButton.selected = YES;
    }
}

- (IBAction)showFullFilters
{
    HLFiltersVC *filtersVC = [[HLIphoneFiltersVC alloc] initWithNibName:@"HLIphoneFiltersVC" bundle:nil];
    filtersVC.searchInfo = self.searchInfo;
    filtersVC.filter = self.filter;
    filtersVC.delegate = self;
    [self.navigationController pushViewController:filtersVC animated:YES];
}

#pragma mark - HLShowHotelProtocol

- (void)showFullHotelInfo:(HLResultVariant *)variant
        visiblePhotoIndex:(NSInteger)visiblePhotoIndex
        indexChangedBlock:(void (^)(NSInteger index))block
                   peeked:(BOOL)peeked
{
    HLHotelDetailsDecorator *decorator = [[HLHotelDetailsDecorator alloc] initWithVariant:variant photoIndex:0 photoIndexUpdater:block filter:self.filter];
    [self.navigationController pushViewController:decorator.detailsVC animated:YES];
}

#pragma mark - HLResultsVCDelegate methods

- (void)variantsFiltered:(NSArray *)variants animated:(BOOL)animated
{
    BOOL shouldReloadTree = ![self.variants isEqualToArray:variants] || [self minPricesChangedFrom:self.variants to:variants];
    if (shouldReloadTree) {
        [self reloadTreeWithVariants:variants];
    }

    BOOL windowIsEmpty = !self.view.window;
    BOOL presentedViewControllerIsOnScreen = self.presentedViewController && !self.presentedViewController.isBeingDismissed;
    if (presentedViewControllerIsOnScreen || windowIsEmpty) {
        self.shouldAnimateFiltersOnViewDidAppear = YES;
    }

    HLCommonResultsVC *resultsController = [self resultsController];
    [resultsController setNeedsUpdateContent];
}

- (HLCommonResultsVC *)resultsController
{
    NSInteger controllersCount = self.navigationController.viewControllers.count;
    if (controllersCount < 2) {
        return nil;
    }
    UIViewController *vc = self.navigationController.viewControllers[controllersCount - 2];
    if ([vc isKindOfClass:[HLCommonResultsVC class]]) {
        return (HLCommonResultsVC *)vc;
    }
    return nil;
}

- (void)reloadTreeWithVariants:(NSArray *)variants
{
    self.variants = variants;

    [self rebuildTreeWithVariants:variants];
    [self mapView:self.mapView regionWillChangeAnimated:YES];
    [self mapView:self.mapView regionDidChangeAnimated:YES];
}

- (BOOL)minPricesChangedFrom:(NSArray *)oldVariants to:(NSArray *)newVariants
{
    BOOL pricesChanged = NO;
    if (oldVariants.count != newVariants.count) {
        pricesChanged = YES;
    } else {
        for (int i = 0; i < oldVariants.count; i++) {
            HLResultVariant * oldVariant = oldVariants[i];
            HLResultVariant * newVariant = newVariants[i];
            if (oldVariant.minPrice != newVariant.minPrice) {
                pricesChanged = YES;

                break;
            }
        }
    }

    return pricesChanged;
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    if ([self shouldCloseSelectedAnnotation]) {
        self.locateMeMapView.locateMeButton.selected = NO;
        [self deselectAnnotation];
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.clusteringEnabled) {
        [super mapView:mapView regionDidChangeAnimated:animated];
    }
    self.clusteringEnabled = YES;
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        MKAnnotationView *pin = [[MKAnnotationView alloc] init];
        pin.image = [UIImage imageNamed:@"userLocationPin"];
        return pin;
    }
    if ([annotation isKindOfClass:[PoiAnnotation class]]) {
        return [HLMapViewConfigurator viewForAnnotation:annotation mapView:mapView city:self.searchInfo.cityByCurrentSearchType];
    }
    if ([annotation isKindOfClass:[TBClusterAnnotation class]]) {
        TBClusterAnnotation *clusterAnnotation = (TBClusterAnnotation *)annotation;
        MKAnnotationView *view;
        if (clusterAnnotation.variants.count == 1) {
            view = [self singleVariantAnnotationView:clusterAnnotation mapView:mapView];
        } else {
            view = [self groupAnnotationView:clusterAnnotation mapView:mapView];
        }
        view.layer.zPosition = HL_HOTEL_ANNOTATION_ZPOSITION;

        return view;
    }

    return nil;
}

-(void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    self.canCloseSelectedAnnotation = NO;
    [super mapView:mapView didAddAnnotationViews:views];
    self.canCloseSelectedAnnotation = YES;

    for (MKAnnotationView *view in views) {
        if ([view isKindOfClass:[TBClusterAnnotationView class]]) {
            [mapView bringSubviewToFront:view];
        } else {
            [mapView sendSubviewToBack:view];
            view.enabled = NO;
        }
    }

}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if (view == self.expandedAnnotation) {
        return;
    }

    if (self.didSelectTime && self.expandedAnnotation && [[NSDate date] timeIntervalSinceDate:self.didSelectTime] < 0.5 && !CGRectEqualToRect(CGRectIntersection(self.expandedAnnotation.frame, view.frame), CGRectZero) ) {
        return;
    }

    self.didSelectTime = [NSDate date];

    if (self.expandedAnnotation != nil) {
        [self deselectAnnotation];
    }

	if ([view.annotation isKindOfClass:[TBClusterAnnotation class]]) {
        TBClusterAnnotation *clusterAnnotation = (TBClusterAnnotation *)view.annotation;
        NSArray *variants = clusterAnnotation.variants;
        if (variants.count > 1) {
            if ([self.mapView canUngroupVariants:variants]) {
                [self.mapView setRegionForVariants:variants insets:[self mapEdgeInsets] animated:YES];
            } else {
                [self.mapView setCenterCoordinate:clusterAnnotation.coordinate animated:YES];
                self.clusteringEnabled = NO;
                [self showMapGroupContents:variants];
            }
        } else if (self.expandedAnnotation != view) {
            self.clusteringEnabled = NO;
            HLResultVariant *variant = [variants lastObject];
            HLSingleAnnotationView *annView = (HLSingleAnnotationView *)view;

            self.canCloseSelectedAnnotation = NO;
            [self.mapView centerOnVariant:variant];
            self.canCloseSelectedAnnotation = YES;
            [self expandSingleAnotationView:annView];
        }
    }

    view.layer.zPosition = HL_SELECTED_ANNOTATION_ZPOSITION;
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[PoiAnnotation class]]) {
        view.enabled = NO;
        [mapView sendSubviewToBack:view];
        view.layer.zPosition = HL_POI_ANNOTATION_ZPOSITION;
    } else {
        view.layer.zPosition = HL_HOTEL_ANNOTATION_ZPOSITION;
    }
}

#pragma mark - HLMapViewDelegate Methods

- (BOOL)mapShouldReactOnTouchAtPoint:(CGPoint)point
{
    CGRect rect = self.expandedAnnotation.frame;
    if (CGRectContainsPoint(rect, point)) {
        return NO;
    }
    [self deselectAnnotation];
    
    return YES;
}

- (void)mapWillReceiveTouchOnAnnotationView:(MKAnnotationView *)view {
    if ([view.annotation isKindOfClass:[PoiAnnotation class]]) {
        view.enabled = YES;
    }
}

#pragma mark - HLNearbyCitiesDetectionDelegate methods

- (void)nearbyCitiesDetectionStarted:(NSNotification *)notification
{
    [self.locateMeMapView startLoadingRoutine];
}

- (void)nearbyCitiesDetected:(NSNotification *)notification
{
    [self.locateMeMapView endLoadingRoutine];
    if ([notification.userInfo[kCurrentLocationDestinationKey] isEqual:kShowCurrentLocationOnMap]) {
        [self locateMeAction];
    }
}

- (void)nearbyCitiesDetectionFailed:(NSNotification *)notification
{
    [self.locateMeMapView endLoadingRoutine];
}

- (void)nearbyCitiesDetectionCancelled:(NSNotification *)notification
{
    [self nearbyCitiesDetectionFailed:notification];
}

- (void)locationServicesAccessFailed:(NSNotification *)notification
{
    [self nearbyCitiesDetectionFailed:notification];
}

- (void)locationDetectionFailed:(NSNotification *)notification
{
    [self nearbyCitiesDetectionFailed:notification];
}

#pragma mark - PeekHotelVCDelegate

- (void)showPeekDetails
{
    [self showFullHotelInfo:self.peekedVariant visiblePhotoIndex:0 indexChangedBlock:nil peeked:true];
}

#pragma mark - FiltersVCDelegate

- (void)didFilterVariants
{
    [self variantsFiltered:self.filter.filteredVariants animated:YES];
}

- (void)locationPointSelected:(HDKLocationPoint *)point
{
    self.filter.distanceLocationPoint = point;
    [self.filter filter];
}

- (void)openPointSelectionScreen
{
}

- (void)showSelectionViewController:(FilterSelectionVC *)selectionVC
{
}

@end
