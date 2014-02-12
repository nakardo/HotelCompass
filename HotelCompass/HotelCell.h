//
//  HotelCell.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompassView.h"
#import "Hotel.h"

static NSString * const kHeadingUpdatedNotification = @"HEADING_UPDATED_NOTIF";

@interface HotelCell : UITableViewCell

@property(nonatomic, weak) IBOutlet CompassView *compassView;
@property(nonatomic, weak) IBOutlet UIView *containerView;
@property(nonatomic, weak) IBOutlet UILabel *nameLabel;
@property(nonatomic, weak) IBOutlet UILabel *addressLabel;
@property(nonatomic, weak) IBOutlet UILabel *distanceLabel;

@property(nonatomic, strong) Hotel *hotel;
@property(nonatomic, strong) CLLocation *location;

- (void)setSchemeColor:(UIColor *)schemeColor;

@end
