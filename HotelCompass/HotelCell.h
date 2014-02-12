//
//  HotelCell.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "CompassView.h"
#import "Hotel.h"

@interface HotelCell : UITableViewCell

- (void)setSchemeColor:(UIColor *)schemeColor;
- (void)setHotel:(Hotel *)hotel withCurrentLocation:(CLLocation *)currentLocation;

@property(nonatomic, weak) IBOutlet CompassView *compassView;
@property(nonatomic, weak) IBOutlet UIView *containerView;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UILabel *distanceLabel;

@end
