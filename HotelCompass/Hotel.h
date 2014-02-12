//
//  Hotel.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/26/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "BaseJSONModel.h"
#import <CoreLocation/CoreLocation.h>

@protocol Hotel
@end

@interface Hotel : BaseJSONModel

- (CLLocation *)location;

@property(nonatomic, strong) NSString *hotelName;
@property(nonatomic, strong) NSString *reviewScore;
@property(nonatomic, strong) NSString *address;
@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

@end
