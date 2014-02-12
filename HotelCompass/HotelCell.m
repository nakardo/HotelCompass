//
//  HotelCell.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "HotelCell.h"
#import "Colours.h"

@implementation HotelCell

- (void)setSchemeColor:(UIColor *)schemeColor {
    NSArray *schemeColors = [schemeColor colorSchemeOfType:ColorSchemeMonochromatic];
    
    _nameLabel.textColor = [schemeColors objectAtIndex:0];
    _addressLabel.textColor = [schemeColors objectAtIndex:1];
    _distanceLabel.textColor = [schemeColors objectAtIndex:3];
    
    _compassView.schemeColor = schemeColor;
    [_compassView setNeedsDisplay];
}

- (void)setHotel:(Hotel *)hotel withCurrentLocation:(CLLocation *)currentLocation {
    _nameLabel.text = hotel.hotelName;
    _addressLabel.text = hotel.address;
    
    CLLocationDistance distance = [currentLocation distanceFromLocation:[hotel location]];
    if (distance > 999) {
        _distanceLabel.text = [NSString stringWithFormat:@"%.1f kms", distance / 1000];
    } else {
        _distanceLabel.text = [NSString stringWithFormat:@"%d mts", (int) distance];
    }
    
}

@end
