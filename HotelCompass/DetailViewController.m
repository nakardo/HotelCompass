//
//  DetailViewController.m
//  HotelCompass
//
//  Created by Diego Acosta on 2/13/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "Colours.h"

@implementation DetailViewController

#pragma mark - Private

- (void)updateMapViewRegion {
    MKMapPoint annotationPoint = MKMapPointForCoordinate(_location.coordinate);
    
    MKMapRect zoomRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
    for (id <MKAnnotation> annotation in _mapView.annotations) {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
        zoomRect = MKMapRectUnion(zoomRect, pointRect);
    }
    
    [_mapView setVisibleMapRect:zoomRect
                    edgePadding:UIEdgeInsetsMake(100, 100, 100, 100)
                       animated:NO];
}

#pragma mark - Public

- (IBAction)didPressShowInBookingButton:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_hotel.url]];
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"More Information";
    self.navigationController.navigationBar.tintColor = _primaryColor;
    
    // booking.com button.
    _bookingButton.layer.cornerRadius = 6;
    _bookingButton.layer.backgroundColor = _secondaryColor.CGColor;
    
    // show location in map.
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(_hotel.latitude, _hotel.longitude);
    
    MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
    annotation.coordinate = location;
    annotation.title = _hotel.hotelName;
    annotation.subtitle = _hotel.address;
    [_mapView addAnnotation:annotation];
    [_mapView selectAnnotation:annotation animated:YES];
    
    [self updateMapViewRegion];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
