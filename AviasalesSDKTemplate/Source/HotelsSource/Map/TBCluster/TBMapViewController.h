#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "HLCommonVC.h"
#import "HLMapView.h"

@interface TBMapViewController : HLCommonVC <MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet HLMapView *mapView;
@property (nonatomic, strong) NSMutableSet *ungroupableAnnotations;

- (void)rebuildTreeWithVariants:(NSArray *)variants;
- (void)cleanMap;

@end
