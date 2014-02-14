//
//  HotelAvailabilityService.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/25/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "HotelAvailabilityService.h"
#import "BookingRequestManager.h"

static NSString* const kServiceURL = @"/json/bookings.getHotelAvailabilityMobile";
static int const kRequestNumberRows = 20;

@implementation HotelAvailabilityService

#pragma mark - Private

+ (NSDictionary *)requestParams:(CLLocation *)currentLocation
{
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    [params setObject:[NSNumber numberWithDouble:currentLocation.coordinate.latitude] forKey:@"latitude"];
    [params setObject:[NSNumber numberWithDouble:currentLocation.coordinate.longitude] forKey:@"longitude"];
    [params setObject:[NSNumber numberWithInt:kRequestNumberRows] forKey:@"rows"];
    
    // today.
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    [params setObject:[dateFormatter stringFromDate:[NSDate date]] forKey:@"arrival_date"];
    
    // tomorrow.
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    [dateComponents setDay:1];
    NSDate *date = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents
                                                                 toDate:[NSDate date]
                                                                options:0];
    [params setObject:[dateFormatter stringFromDate:date] forKey:@"departure_date"];
    
    return [NSDictionary dictionaryWithDictionary:params];
}

#pragma mark - Initialization

- (HotelAvailabilityService *)initWithDelegate:(id<HotelAvailabilityServiceDelegate>)aDelegate
{
    if ((self = [super init])) {
        self.delegate = aDelegate;
    }
    
    return self;
}

#pragma mark - Public

- (void)getHotelsNearby:(CLLocation *)currentLocation
{
    // callbacks.
    void (^success)(AFHTTPRequestOperation *operation, id responseObject) =
    ^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *response = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        AvailableHotels * theHotels = [[AvailableHotels alloc] initWithString:response error:nil];
        [self.delegate didLoadHotels:theHotels];
    };
    
    void (^failure)(AFHTTPRequestOperation *operation, NSError *error) =
    ^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.delegate didFailLoadingHotels];
    };
    
    // pull hotels for current location.
    [[BookingRequestManager sharedManager] GET:kServiceURL
                                    parameters:[HotelAvailabilityService requestParams:currentLocation]
                                       success:success
                                       failure:failure];
}

@end
