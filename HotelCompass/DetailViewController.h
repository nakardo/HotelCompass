//
//  DetailViewController.h
//  HotelCompass
//
//  Created by Diego Acosta on 2/13/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Hotel.h"

@interface DetailViewController : UIViewController<CLLocationManagerDelegate>

@property(nonatomic, weak) CLLocation *location;
@property(nonatomic, strong) Hotel *hotel;
@property(nonatomic, strong) UIColor *primaryColor;
@property(nonatomic, strong) UIColor *secondaryColor;

@property(nonatomic, weak) IBOutlet MKMapView *mapView;
@property(nonatomic, weak) IBOutlet UIButton *bookingButton;

- (IBAction)didPressShowInBookingButton:(id)sender;

@end
