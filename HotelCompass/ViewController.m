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

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.hotels = [NSArray array];
    
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.separatorColor = [UIColor blackColor];
    
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
    
    cell.hotel = [_hotels objectAtIndex:indexPath.row];
    cell.location = _location;
    cell.containerView.backgroundColor = [_backgroundColors objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor clearColor];
    
    // update color.
    [cell setSchemeColor:[_backgroundColors objectAtIndex:indexPath.row]];
    
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
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    self.heading = newHeading;
    
    NSDictionary *info = [NSDictionary dictionaryWithObject:_heading forKey:@"heading"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHeadingUpdatedNotification
                                                        object:nil
                                                      userInfo:info];
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
    
    // we're done.
    [_activityIndicator stopAnimating];
    [_tableView reloadData];
}

- (void)didFailLoadingHotels
{
    return;
}

@end
