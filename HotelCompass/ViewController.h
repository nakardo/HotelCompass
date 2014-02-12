//
//  ViewController.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "HotelAvailabilityService.h"

@interface ViewController : UITableViewController
<UITableViewDataSource, UITableViewDelegate, HotelAvailabilityServiceDelegate, CLLocationManagerDelegate>

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, strong) CLHeading *heading;
@property(nonatomic, strong) NSArray *hotels;
@property(nonatomic, strong) NSArray *backgroundColors;

@end
