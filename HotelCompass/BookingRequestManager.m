//
//  BookingRequestManager.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/25/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "BookingRequestManager.h"
#import "Settings.h"

static NSString * const kBaseURL = @"https://iphone-xml.booking.com:443";

@implementation BookingRequestManager

#pragma mark - initialization

- (id)initWithBaseURL:(NSURL *)url
{
    if ((self = [super initWithBaseURL:url])) {
        self.responseSerializer = [AFHTTPResponseSerializer serializer];
        [self.requestSerializer setAuthorizationHeaderFieldWithUsername:kBookingAPIAuthUserId
                                                               password:kBookingAPIAuthPassword];
    }
    
    return self;
}

+ (BookingRequestManager *)sharedManager
{
    static dispatch_once_t pred;
    
    static BookingRequestManager *_sharedManager = nil;
    dispatch_once(&pred, ^{
        _sharedManager = [[self alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
    });
    
    return _sharedManager;
}

@end
