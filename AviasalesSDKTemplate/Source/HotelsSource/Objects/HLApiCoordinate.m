#import "HLApiCoordinate.h"


@implementation HLApiCoordinate

+ (instancetype)coordinateWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    return [[HLApiCoordinate alloc] initWithLatitude:latitude longitude:longitude];
}

- (HLApiCoordinate *)initWithLatitude:(NSNumber *)latitude longitude:(NSNumber *)longitude
{
    self = [super init];
    if (self) {
        self.latitude = latitude;
        self.longitude = longitude;
    }
    
    return self;
}

- (BOOL) isEqual:(id)object
{
	if([object isKindOfClass:[HLApiCoordinate class]] == NO){
		return NO;
	}
	HLApiCoordinate * otherCoordinate = (HLApiCoordinate *)object;
	return ([_latitude isEqualToNumber:otherCoordinate.latitude] && [_longitude isEqualToNumber:otherCoordinate.longitude]);
}

- (id) copy
{
	HLApiCoordinate * coord = [HLApiCoordinate new];
	coord.latitude = [_latitude copy];
	coord.longitude = [_longitude copy];
	return coord;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:_latitude forKey:@"latitude"];
	[coder encodeObject:_longitude forKey:@"longitude"];
}

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super init]) {
		_latitude = [coder decodeObjectForKey:@"latitude"];
		_longitude = [coder decodeObjectForKey:@"longitude"];
    }
    return self;
}


@end
