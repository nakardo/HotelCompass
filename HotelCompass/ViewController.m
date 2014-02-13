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
#import "DetailViewController.h"

@interface ViewController ()

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, strong) CLHeading *heading;
@property(nonatomic, strong) NSArray *hotels;
@property(nonatomic, strong) NSArray *primaryColors;
@property(nonatomic, strong) NSArray *primaryGradient;
@property(nonatomic, strong) NSArray *secondaryColors;
@property(nonatomic, strong) NSArray *secondaryGradient;

@end

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

- (void)updateRow:(HotelCell *)cell atPosition:(NSInteger)row
                           withPrimaryGradient:(NSArray *)primaryGradient
                          andSecondaryGradient:(NSArray *)secondaryGradient
{
    // primary colors.
    [cell setSchemeColor:[primaryGradient objectAtIndex:row]];
    cell.backgroundColor = [primaryGradient objectAtIndex:row];
    
    // secondary colors.
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [secondaryGradient objectAtIndex:row];
}

- (void)performRowsAnimation {
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    
    // generate temporary secondary colors to keep animation consistent.
    NSArray *tmpSecondaryColors = [ColorUtils generateGradientColorsAndExclude:_secondaryColors];
    NSArray *tmpSecondaryGradient = [ColorUtils generateGradientFromColor:[_secondaryColors objectAtIndex:0]
                                                                  toColor:[_secondaryColors objectAtIndex:1]
                                                                withSteps:[_hotels count]];
    
    // set new color for selected row, and remove selection inmediately.
    HotelCell *selectedCell = (HotelCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [self updateRow:selectedCell atPosition:indexPath.row
                        withPrimaryGradient:_secondaryGradient
                       andSecondaryGradient:tmpSecondaryGradient];
    [_tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // make animation on group of two rows on opposite sides.
    float delay = 0; int i = 1;
    BOOL hasMoreGroupsToAnimate = YES;
    while (hasMoreGroupsToAnimate) {
        
        // top row.
        HotelCell *topCell = nil;
        if (indexPath.row - i > -1) {
            NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row - i inSection:indexPath.section];
            topCell = (HotelCell *)[_tableView cellForRowAtIndexPath:idx];
        }
        
        // top row.
        HotelCell *bottomCell = nil;
        if (indexPath.row + i < [_hotels count]) {
            NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row + i inSection:indexPath.section];
            bottomCell = (HotelCell *)[_tableView cellForRowAtIndexPath:idx];
        }
        
        // run animation for current group.
        [UIView animateWithDuration:0.5
                              delay:delay
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (topCell != nil) {
                                 [self updateRow:topCell atPosition:indexPath.row - i
                                                withPrimaryGradient:_secondaryGradient
                                               andSecondaryGradient:tmpSecondaryGradient];
                             }
                             
                             if (bottomCell != nil) {
                                 [self updateRow:bottomCell atPosition:indexPath.row + i
                                                   withPrimaryGradient:_secondaryGradient
                                                  andSecondaryGradient:tmpSecondaryGradient];
                             }
                         }
                         completion:nil];
        delay+=.1;
        i++; hasMoreGroupsToAnimate = topCell != nil || bottomCell != nil;
    }
    
    // swap colors.
    self.primaryColors = _secondaryColors;
    self.primaryGradient = _secondaryGradient;
    
    self.secondaryColors = tmpSecondaryColors;
    self.secondaryGradient = tmpSecondaryGradient;
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Hotels Nearby";
    
    self.hotels = [NSArray array];
    
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.separatorColor = [UIColor blackColor];
    
    [self startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([_hotels count] > 0) [self performRowsAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *controller = [segue destinationViewController];
    
    NSInteger row = [_tableView indexPathForSelectedRow].row;
    controller.hotel = [_hotels objectAtIndex:row];
    controller.primaryColor = [_primaryGradient objectAtIndex:row];
    controller.secondaryColor = [_secondaryGradient objectAtIndex:row];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    HotelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HotelCell"];
    
    // content.
    cell.hotel = [_hotels objectAtIndex:indexPath.row];
    cell.location = _location;
    cell.heading = _heading;
    
    // update colors.
    [self updateRow:cell atPosition:indexPath.row
                withPrimaryGradient:_primaryGradient
               andSecondaryGradient:_secondaryGradient];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_hotels count];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 122.0;
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
    
    NSDictionary *info = [NSDictionary dictionaryWithObject:_location forKey:@"location"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdatedNotification
                                                        object:nil
                                                      userInfo:info];
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
    self.primaryColors = [ColorUtils generateGradientColors];
    self.primaryGradient = [ColorUtils generateGradientFromColor:[_primaryColors objectAtIndex:0]
                                                         toColor:[_primaryColors objectAtIndex:1]
                                                       withSteps:[_hotels count]];
    
    self.secondaryColors = [ColorUtils generateGradientColorsAndExclude:_primaryColors];
    self.secondaryGradient = [ColorUtils generateGradientFromColor:[_secondaryColors objectAtIndex:0]
                                                           toColor:[_secondaryColors objectAtIndex:1]
                                                         withSteps:[_hotels count]];
    
    // we're done.
    [_activityIndicator stopAnimating];
    [_tableView reloadData];
}

- (void)didFailLoadingHotels
{
    NSLog(@"Unable to load hotels, please check API call response.");
}

@end
