//
//  ViewController.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HotelAvailabilityService.h"

@interface ViewController : UIViewController
<UITableViewDataSource, UITableViewDelegate, HotelAvailabilityServiceDelegate, CLLocationManagerDelegate>

@property(nonatomic, weak) IBOutlet UITableView *tableView;
@property(nonatomic, weak) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
