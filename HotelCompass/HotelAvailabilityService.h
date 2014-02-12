//
//  HotelAvailabilityService.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/25/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "AvailableHotels.h"
#import <CoreLocation/CoreLocation.h>

@protocol HotelAvailabilityServiceDelegate <NSObject>

@required
- (void)didLoadHotels:(AvailableHotels *)theHotels;
- (void)didFailLoadingHotels;

@end

@interface HotelAvailabilityService : NSObject

@property(nonatomic, weak) id<HotelAvailabilityServiceDelegate> delegate;

- (HotelAvailabilityService *)initWithDelegate:(id<HotelAvailabilityServiceDelegate>)aDelegate;
- (void)getHotelsNearby:(CLLocation *)currentLocation;

@end
