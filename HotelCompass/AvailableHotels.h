//
//  AvailableHotels.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/26/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "BaseJSONModel.h"
#import "Hotel.h"

@interface AvailableHotels : JSONModel

@property(nonatomic) int count;
@property(nonatomic, retain) NSArray<Hotel> *result;

@end
