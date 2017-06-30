//
//  TBCoordinateQuadTree.m
//  TBAnnotationClustering
//
//  Created by Theodore Calmes on 9/27/13.
//  Copyright (c) 2013 Theodore Calmes. All rights reserved.
//

#import "TBCoordinateQuadTree.h"
#import "TBClusterAnnotation.h"
#import "HLResultVariant.h"

typedef struct TBHotelInfo
{
    char* hotelId;
} TBHotelInfo;

static TBQuadTreeNodeData TBDataFromVariant(HLResultVariant * variant)
{
    TBHotelInfo * hotelInfo = malloc(sizeof(TBHotelInfo));
    NSString *hotelId = variant.hotel.hotelId;
    hotelInfo->hotelId = malloc(sizeof(char) * hotelId.length + 1);
    strncpy(hotelInfo->hotelId, [hotelId UTF8String], hotelId.length + 1);
    
    return TBQuadTreeNodeDataMake(variant.hotel.latitude, variant.hotel.longitude, hotelInfo);
}


static TBBoundingBox TBBoundingBoxForMapRect(MKMapRect mapRect)
{
    CLLocationCoordinate2D topLeft = MKCoordinateForMapPoint(mapRect.origin);
    CLLocationCoordinate2D botRight = MKCoordinateForMapPoint(MKMapPointMake(MKMapRectGetMaxX(mapRect), MKMapRectGetMaxY(mapRect)));

    CLLocationDegrees minLat = botRight.latitude;
    CLLocationDegrees maxLat = topLeft.latitude;

    CLLocationDegrees minLon = topLeft.longitude;
    CLLocationDegrees maxLon = botRight.longitude;

    return TBBoundingBoxMake(minLat, minLon, maxLat, maxLon);
}

static float TBCellSizeForZoomScale(MKZoomScale zoomScale)
{
    return 100;
}

@interface TBCoordinateQuadTree ()
{
}
@property (nonatomic, strong) NSArray * variants;
@property (nonatomic, strong) NSMutableDictionary * variantsDict;
@end

@implementation TBCoordinateQuadTree

- (void)buildTreeWithVariants:(NSArray *)variants
{
    self.variants = variants;
    @autoreleasepool {

        NSInteger count = variants.count;
        self.variantsDict = [NSMutableDictionary new];

        TBQuadTreeNodeData *dataArray = malloc(sizeof(TBQuadTreeNodeData) * count);
        for (NSInteger i = 0; i < count; i++) {
            HLResultVariant * variant = variants[i];
            dataArray[i] = TBDataFromVariant(variant);
            [self.variantsDict setObject:variant forKey:variant.hotel.hotelId];
        }

        TBBoundingBox world = TBBoundingBoxMake(-180, -180, 180, 180);
        _root = TBQuadTreeBuildWithData(dataArray, count, world, 4);
    }
}

- (NSArray *)clusteredAnnotationsWithinMapRect:(MKMapRect)rect withZoomScale:(double)zoomScale
{
    double TBCellSize = TBCellSizeForZoomScale(zoomScale);
    double scaleFactor = zoomScale / TBCellSize;

    NSInteger minX = floor(MKMapRectGetMinX(rect) * scaleFactor);
    NSInteger maxX = floor(MKMapRectGetMaxX(rect) * scaleFactor);
    NSInteger minY = floor(MKMapRectGetMinY(rect) * scaleFactor);
    NSInteger maxY = floor(MKMapRectGetMaxY(rect) * scaleFactor);

    NSMutableArray *clusteredAnnotations = [[NSMutableArray alloc] init];
    for (NSInteger x = minX; x <= maxX; x++) {
        for (NSInteger y = minY; y <= maxY; y++) {
            MKMapRect mapRect = MKMapRectMake(x / scaleFactor, y / scaleFactor, 1.0 / scaleFactor, 1.0 / scaleFactor);
            
            __block double totalX = 0;
            __block double totalY = 0;
            __block int count = 0;
            __block NSMutableArray * variants = [NSMutableArray new];

            NSMutableArray *names = [[NSMutableArray alloc] init];
            NSMutableArray *phoneNumbers = [[NSMutableArray alloc] init];

            TBQuadTreeGatherDataInRange(self.root, TBBoundingBoxForMapRect(mapRect), ^(TBQuadTreeNodeData data) {
                totalX += data.x;
                totalY += data.y;

                TBHotelInfo hotelInfo = *(TBHotelInfo *)data.data;
                NSString * hotelId = [NSString stringWithFormat:@"%s", hotelInfo.hotelId];
                HLResultVariant * variant = [self variantWithId:hotelId];
                if(variant){
                    count++;
                    [variants addObject:variant];
                }
            });

            if (count == 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX, totalY);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate variants:variants];
                annotation.title = [names lastObject];
                annotation.subtitle = [phoneNumbers lastObject];
                [clusteredAnnotations addObject:annotation];
            }

            if (count > 1) {
                CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(totalX / count, totalY / count);
                TBClusterAnnotation *annotation = [[TBClusterAnnotation alloc] initWithCoordinate:coordinate variants:variants];
                [clusteredAnnotations addObject:annotation];
            }
        }
    }
    return [NSArray arrayWithArray:clusteredAnnotations];
}

- (HLResultVariant *) variantWithId:(NSString *)hotelId
{
    return [self.variantsDict objectForKey:hotelId];
}

@end
