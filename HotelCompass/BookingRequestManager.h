//
//  BookingRequestManager
//  HotelCompass
//
//  Created by Diego Acosta on 1/25/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <AFNetworking/AFHTTPRequestOperationManager.h>

@interface BookingRequestManager : AFHTTPRequestOperationManager

+ (BookingRequestManager *)sharedManager;

@end
