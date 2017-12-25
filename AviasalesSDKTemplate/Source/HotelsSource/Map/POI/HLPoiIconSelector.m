#import "HLPoiIconSelector.h"
#import "HLPoiManager.h"
#import <MapKit/MapKit.h>

static NSDictionary * nameAccordingToCategoryMap;
static NSString * kDefaultMapPoiIcon = @"poiDefaultIcon";
static NSDictionary * nameAccordingToCategoryList;
static NSString * kDefaultListPoiIcon = @"poiDefaultIconList";
static NSString * reuseIdentifier = @"poiAnnotationView";

static NSString *kSaintPetersburgCityId = @"12196";
static NSString *kMoscowCityId = @"12153";

@implementation HLPoiIconSelector

+ (MKAnnotationView *)annotationView:(PoiAnnotation *)annotation mapView:(MKMapView *)mapView city:(HDKCity *)city
{
    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
    if (!annotationView) {
        annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        annotationView.canShowCallout = YES;
    }
    annotationView.layer.zPosition = HL_POI_ANNOTATION_ZPOSITION;
    HDKLocationPoint * poi = annotation.poi;
    UIImage * poiImage = [self mapPoiIcon:poi city:(HDKCity *)city];
    if (poiImage) {
        annotationView.image = poiImage;
        return annotationView;
    }
    return nil;
}

+ (UIImage *)listPoiIcon:(HDKLocationPoint *)poi city:(HDKCity *)city
{
    if (nameAccordingToCategoryList == nil) {
        nameAccordingToCategoryList = [self createNameAccordingToCategoryList];
    }

    NSString *imageName = nil;
    if ([poi.category isEqualToString:HDKLocationPointCategory.kMetroStation]) {
        if ([city.cityId isEqualToString:kSaintPetersburgCityId]) {
            imageName = @"poiMetroSpbIconList";
        }

        if ([city.cityId isEqualToString:kMoscowCityId]) {
            imageName = @"poiMetroMoscowIconList";
        }
    }
    if (imageName == nil) {
        imageName = nameAccordingToCategoryList[poi.category] ?: kDefaultListPoiIcon;
    }

    return [UIImage imageNamed:imageName];
}

+ (UIImage *)mapPoiIcon:(HDKLocationPoint *)poi city:(HDKCity *)city
{
    if (nameAccordingToCategoryMap == nil) {
        nameAccordingToCategoryMap = [self createNameAccordingToCategoryMap];
    }

    NSString *imageName = nil;
    if ([poi.category isEqualToString:HDKLocationPointCategory.kMetroStation]) {
        if ([city.cityId isEqualToString:kSaintPetersburgCityId]) {
            imageName = @"poiMetroSpbIcon";
        }

        if ([city.cityId isEqualToString:kMoscowCityId]) {
            imageName = @"poiMetroMoscowIcon";
        }
    }
    if (imageName == nil) {
        imageName = nameAccordingToCategoryMap[poi.category] ?: kDefaultMapPoiIcon;
    }

    return [UIImage imageNamed:imageName];
}

+ (NSDictionary *)createNameAccordingToCategoryList
{
    return @{HDKLocationPointCategory.kAirport : @"poiAirportIconList",
             HDKLocationPointCategory.kTrainStation : @"poiStationIconList",
             HDKLocationPointCategory.kMetroStation : @"poiMetroIconList",
             HDKLocationPointCategory.kBeach : @"poiBeachIconList",
             @"stadium" : @"poiStadiumIconList",
             HDKLocationPointCategory.kSkilift : @"poiSkiIconList",
             HDKLocationPointCategory.kCityCenter : @"poiCenterIconList",
             HDKLocationPointCategory.kUserLocation : @"poiUserIconList",
             };
}

+ (NSDictionary *)createNameAccordingToCategoryMap
{
    return @{HDKLocationPointCategory.kAirport : @"poiAirportIcon",
             HDKLocationPointCategory.kTrainStation : @"poiStationIcon",
             HDKLocationPointCategory.kMetroStation : @"poiMetroIcon",
             HDKLocationPointCategory.kBeach : @"poiBeachIcon",
             @"stadium" : @"poiStadiumIcon",
             HDKLocationPointCategory.kSkilift : @"poiSkiIcon",
             HDKLocationPointCategory.kCityCenter : @"poiCenterIcon",
             HDKLocationPointCategory.kUserLocation : kDefaultMapPoiIcon,
             };
}

@end
