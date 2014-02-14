//
//  Hotel.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/26/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "Hotel.h"

@implementation Hotel

- (CLLocation *)location
{
    return [[CLLocation alloc] initWithLatitude:_latitude longitude:_longitude];
}

@end
