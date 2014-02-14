//
//  HotelCell.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "HotelCell.h"
#import "Colours.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation HotelCell

#pragma mark - Private

- (double)calculateAngleFromCurrentLocation:(CLLocationCoordinate2D)current
                                 toLocation:(CLLocationCoordinate2D)fixed
{
    double longitude = fixed.longitude - current.longitude;
    
    double y = sin(longitude) * cos(fixed.latitude);
    double x = cos(current.latitude) * sin(fixed.latitude) -
    sin(current.latitude) * cos(fixed.latitude) * cos(longitude);
    
    double degrees = RADIANS_TO_DEGREES(atan2(y, x));
    return degrees < 0 ? degrees = -degrees : 360 - degrees;
}

- (void)updateLocation:(NSNotification *)notification
{
    NSDictionary *info = notification.userInfo;
    if ([info objectForKey:@"location"] != nil) {
        self.location = (CLLocation *)[info objectForKey:@"location"];
    }
}

- (void)updateHeading:(NSNotification *)notification
{
    
    // make sure we've a location already since it's required to calculate heading direction.
    NSDictionary *info = notification.userInfo;
    if (_location != nil && [info objectForKey:@"heading"] != nil) {
        self.heading = (CLHeading *)[info objectForKey:@"heading"];
    }
}

#pragma mark - Public

- (void)setPrimaryColor:(UIColor *)primaryColor andSecondaryColor:(UIColor *)secondaryColor
{
    // primary colors.
    NSArray *primarySchemeColors = [primaryColor colorSchemeOfType:ColorSchemeMonochromatic];
    _nameLabel.textColor = [primarySchemeColors objectAtIndex:0];
    _addressLabel.textColor = [primarySchemeColors objectAtIndex:1];
    _distanceLabel.textColor = [primarySchemeColors objectAtIndex:3];
    
    // highlighted colors.
    NSArray *secondarySchemeColors = [secondaryColor colorSchemeOfType:ColorSchemeMonochromatic];
    _nameLabel.highlightedTextColor = [secondarySchemeColors objectAtIndex:0];
    _addressLabel.highlightedTextColor = [secondarySchemeColors objectAtIndex:1];
    _distanceLabel.highlightedTextColor = [secondarySchemeColors objectAtIndex:3];
    
    // propagate color changes to compass view.
    _compassView.schemeColor = primaryColor;
    [_compassView setNeedsDisplay];
}

#pragma mark - NSObject

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateLocation:)
                                                     name:kLocationUpdatedNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(updateHeading:)
                                                     name:kHeadingUpdatedNotification
                                                   object:nil];
    }
    
    return self;
}

#pragma mark - Overriden Properties

- (void)setHotel:(Hotel *)hotel
{
    _hotel = hotel;
    
    _nameLabel.text = hotel.hotelName;
    _addressLabel.text = hotel.address;
}

- (void)setLocation:(CLLocation *)location
{
    _location = location;
    
    CLLocationDistance distance = [_location distanceFromLocation:[_hotel location]];
    if (distance > 999) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1f kms", distance / 1000];
    } else {
        _distanceLabel.text = [NSString stringWithFormat:@"%d mts", (int) distance];
    }
}

- (void)setHeading:(CLHeading *)heading
{
    CLLocationCoordinate2D toLocation = { _hotel.latitude, _hotel.longitude };
    double degrees = [self calculateAngleFromCurrentLocation:_location.coordinate
                                                  toLocation:toLocation];
    double rads = DEGREES_TO_RADIANS(degrees - heading.trueHeading);
    
    // rotate compass.
    [UIView animateWithDuration:1.0 animations:^{
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationBeginsFromCurrentState:YES];
        _compassView.transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    }];
}

@end
