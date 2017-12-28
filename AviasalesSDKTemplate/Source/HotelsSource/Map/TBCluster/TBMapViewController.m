#import "TBMapViewController.h"
#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotationView.h"
#import "TBClusterAnnotation.h"
#import "HLSingleAnnotationView.h"
#import "MKMapView+Refresh.h"

@interface TBMapViewController ()
@property (strong, nonatomic) TBCoordinateQuadTree *coordinateQuadTree;
@end

@implementation TBMapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.ungroupableAnnotations = [NSMutableSet new];
}

- (void) rebuildTreeWithVariants:(NSArray *)variants
{
    self.coordinateQuadTree = [[TBCoordinateQuadTree alloc] init];
    [self.coordinateQuadTree buildTreeWithVariants:variants];
}

- (void)addBounceAnnimationToView:(UIView *)view
{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.scale"];

    bounceAnimation.values = @[@(0.05), @(1.1), @(0.9), @(1)];

    bounceAnimation.duration = 0.6;
    NSMutableArray *timingFunctions = [[NSMutableArray alloc] initWithCapacity:bounceAnimation.values.count];
    for (NSUInteger i = 0; i < bounceAnimation.values.count; i++) {
        [timingFunctions addObject:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    }
    [bounceAnimation setTimingFunctions:timingFunctions.copy];
    bounceAnimation.removedOnCompletion = NO;

    [view.layer addAnimation:bounceAnimation forKey:@"bounce"];
}

- (void)updateMapViewAnnotationsWithAnnotations:(NSArray *)annotations
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray * mapAnnotations = self.mapView.annotations.copy;
        
        if (mapAnnotations == nil || annotations == nil) {
            return;
        }
        NSMutableSet *before = [NSMutableSet setWithArray:mapAnnotations];
        [before removeObject:[self.mapView userLocation]];
        [before minusSet:self.ungroupableAnnotations];
        NSSet *after = [NSSet setWithArray:annotations];
        
        NSMutableSet *toKeep = [NSMutableSet setWithSet:before];
        [toKeep intersectSet:after];
        
        NSMutableSet *toAdd = [NSMutableSet setWithSet:after];
        [toAdd minusSet:toKeep];
        
        NSMutableSet *toRemove = [NSMutableSet setWithSet:before];
        [toRemove minusSet:after];
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.mapView addAnnotations:[toAdd allObjects]];
                [self.mapView removeAnnotations:[toRemove allObjects]];

                for (id<MKAnnotation> annotation in toKeep){
                    id annotationView = [self.mapView viewForAnnotation: annotation];
                    if ([annotationView isKindOfClass:[HLSingleAnnotationView class]]){
                        [(HLSingleAnnotationView *)annotationView updateContentAndCollapseIfExpanded];
                    }
                }
        }];
    });
}

#pragma mark - Public

- (void)cleanMap
{
    [self rebuildTreeWithVariants:nil];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self updateMapViewAnnotationsWithAnnotations:nil];
}

#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    MKMapRect rect = mapView.visibleMapRect;
    double scale = self.mapView.bounds.size.width / rect.size.width;

    [[NSOperationQueue new] addOperationWithBlock:^{
        NSArray *annotations = [self.coordinateQuadTree clusteredAnnotationsWithinMapRect:rect withZoomScale:scale];
        [self updateMapViewAnnotationsWithAnnotations:annotations];
    }];
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    for (UIView *view in views) {
        [self addBounceAnnimationToView:view];
    }
    [self.mapView hl_refreshAnnotationsAnimated:NO];
}

@end
