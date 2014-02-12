//
//  ViewController.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "ViewController.h"
#import "HotelAvailabilityService.h"
#import "HotelCell.h"
#import "Colours.h"
#import "ColorUtils.h"
#import "HexColor.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation ViewController

#pragma mark - Private

- (void)startUpdatingLocation {
    self.locationManager = [[CLLocationManager alloc] init];
	_locationManager.delegate = self;
    
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    
    [_locationManager startUpdatingLocation];
	[_locationManager startUpdatingHeading];
}

- (double)calculateAngleFromCurrentLocation:(CLLocationCoordinate2D)current
                                 toLocation:(CLLocationCoordinate2D)fixed {
    double longitude = fixed.longitude - current.longitude;
    
    double y = sin(longitude) * cos(fixed.latitude);
    double x = cos(current.latitude) * sin(fixed.latitude) -
        sin(current.latitude) * cos(fixed.latitude) * cos(longitude);
    
    double degrees = RADIANS_TO_DEGREES(atan2(y, x));
    return degrees < 0 ? degrees = -degrees : 360 - degrees;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hotels = [NSArray array];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor blackColor];
    self.tableView.separatorColor = [UIColor blackColor];
    
    [self startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HotelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotelCell"];
    
    Hotel *hotel = [_hotels objectAtIndex:indexPath.row];
    CLLocationCoordinate2D toLocation = { hotel.latitude, hotel.longitude };
    double degrees = [self calculateAngleFromCurrentLocation:_location.coordinate
                                                  toLocation:toLocation];
    double rads = DEGREES_TO_RADIANS(degrees - _heading.trueHeading);
    
    cell.containerView.backgroundColor = [_backgroundColors objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    // rotate compass.
    CGAffineTransform transform = CGAffineTransformRotate(CGAffineTransformIdentity, rads);
    cell.compassView.transform = transform;
    
    // row content.
    [cell setSchemeColor:[_backgroundColors objectAtIndex:indexPath.row]];
    [cell setHotel:[_hotels objectAtIndex:indexPath.row] withCurrentLocation:_location];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_hotels count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 122.0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    cell.contentView.frame = CGRectMake(0, 0, 55, 80);
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([_hotels count] == 0 && _location == nil) {
        [[[HotelAvailabilityService alloc] initWithDelegate:self] getHotelsNearby:newLocation];
    }
    self.location = newLocation;
    
    [self.tableView reloadData];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    self.heading = newHeading;
    [self.tableView reloadData];
}

#pragma mark - HotelAvailabilityServiceDelegate

- (void)didLoadHotels:(AvailableHotels *)theHotels
{
    // sort results by distance.
    self.hotels = [theHotels.result sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2) {
        CLLocation *l1 = [(Hotel *)o1 location], *l2 = [(Hotel *)o2 location];
        
        CLLocationDistance d1 = [l1 distanceFromLocation:_location];
        CLLocationDistance d2 = [l2 distanceFromLocation:_location];
        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];
    
    // generate random gradient using ios7 theme.
    self.backgroundColors = [ColorUtils generateRandomGradientWithSteps:[_hotels count]];
    
    // default gradient with booking.com colors.
    /*
    self.backgroundColors = [ColorUtils generateGradientFromColor:[UIColor colorWithHexString:@"0896ff" alpha:1]
                                                          toColor:[UIColor colorWithHexString:@"feba02" alpha:1]
                                                        withSteps:[_hotels count]];
    */
}

- (void)didFailLoadingHotels
{
    return;
}

@end
