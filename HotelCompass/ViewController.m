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
#import "NyanView.h"

@implementation ViewController {
    CLLocationManager *locationManager;
    CLLocation *location;
    CLHeading *heading;
    NSArray *hotels;
    NSArray *primaryGradient;
    NSArray *secondaryColors;
    NSArray *secondaryGradient;
    UIView *nyanView;
}

#pragma mark - Private

- (void)startUpdatingLocation
{
    locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
    
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [locationManager requestWhenInUseAuthorization];
    }
    
    [locationManager startUpdatingLocation];
	[locationManager startUpdatingHeading];
}

- (void)updateRow:(HotelCell *)cell atPosition:(NSInteger)row
                           withPrimaryGradient:(NSArray *)aPrimaryGradient
                          andSecondaryGradient:(NSArray *)aSecondaryGradient
{
    // primary colors.
    [cell setPrimaryColor:[aPrimaryGradient objectAtIndex:row]
        andSecondaryColor:[aSecondaryGradient objectAtIndex:row]];
    cell.backgroundColor = [aPrimaryGradient objectAtIndex:row];
    
    // secondary colors.
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [aSecondaryGradient objectAtIndex:row];
}

- (void)performRowsAnimation
{
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    
    // generate temporary secondary colors to keep animation consistent.
    NSArray *tmpSecondaryColors = [ColorUtils generateGradientColorsAndExclude:secondaryColors];
    NSArray *tmpSecondaryGradient = [ColorUtils generateGradientFromColor:[tmpSecondaryColors objectAtIndex:0]
                                                                  toColor:[tmpSecondaryColors objectAtIndex:1]
                                                                withSteps:[hotels count]];
    
    // set new color for selected row, and remove selection inmediately.
    HotelCell *selectedCell = (HotelCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [self updateRow:selectedCell atPosition:indexPath.row - 1
                        withPrimaryGradient:secondaryGradient
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
        if (indexPath.row + i < [hotels count] + 1) {
            NSIndexPath *idx = [NSIndexPath indexPathForRow:indexPath.row + i inSection:indexPath.section];
            bottomCell = (HotelCell *)[_tableView cellForRowAtIndexPath:idx];
        }
        
        // run animation for current group.
        [UIView animateWithDuration:0.5
                              delay:delay
                            options:UIViewAnimationOptionBeginFromCurrentState|UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             if (topCell != nil) {
                                 [self updateRow:topCell atPosition:indexPath.row - 1 - i
                                                withPrimaryGradient:secondaryGradient
                                               andSecondaryGradient:tmpSecondaryGradient];
                             }
                             
                             if (bottomCell != nil) {
                                 [self updateRow:bottomCell atPosition:indexPath.row - 1 + i
                                                   withPrimaryGradient:secondaryGradient
                                                  andSecondaryGradient:tmpSecondaryGradient];
                             }
                         }
                         completion:nil];
        delay+=.1;
        i++; hasMoreGroupsToAnimate = topCell != nil || bottomCell != nil;
    }
    
    // swap colors.
    primaryGradient = secondaryGradient;
    
    secondaryColors = tmpSecondaryColors;
    secondaryGradient = tmpSecondaryGradient;
}

- (void)didPressGithubButton
{
    NSURL *url = [NSURL URLWithString:@"https://github.com/dmacosta/HotelCompass"];
    [[UIApplication sharedApplication] openURL:url];
}


#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"Hotels Nearby";
    
    // add github button.
    UIBarButtonItem *githubButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"github"]
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(didPressGithubButton)];
    self.navigationItem.rightBarButtonItem = githubButton;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    hotels = [NSArray array];
    
    // nyan nyan nyan.
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    nyanView = [[NyanView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
    [_tableView setContentInset:UIEdgeInsetsMake(-[UIScreen mainScreen].bounds.size.height, 0, 0, 0)];
    
    // setup layout.
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.separatorColor = [UIColor blackColor];
    
    [self startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([hotels count] > 0) [self performRowsAnimation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    DetailViewController *controller = [segue destinationViewController];
    
    NSInteger row = [_tableView indexPathForSelectedRow].row - 1;
    controller.location = location;
    controller.hotel = [hotels objectAtIndex:row];
    controller.primaryColor = [primaryGradient objectAtIndex:row];
    controller.secondaryColor = [secondaryGradient objectAtIndex:row];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        UITableViewCell *nyanCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
        nyanCell.selectionStyle = UITableViewCellSelectionStyleNone;
        nyanCell.backgroundColor = [UIColor clearColor];
        [nyanCell addSubview:nyanView];
        
        cell = nyanCell;
    } else {
        HotelCell *hotelCell = [tableView dequeueReusableCellWithIdentifier:@"HotelCell"];
        
        NSUInteger row = indexPath.row - 1;
        
        // content.
        hotelCell.hotel = [hotels objectAtIndex:row];
        hotelCell.location = location;
        hotelCell.heading = heading;
        
        // update colors.
        [self updateRow:hotelCell atPosition:row
                         withPrimaryGradient:primaryGradient
                        andSecondaryGradient:secondaryGradient];
        
        cell = hotelCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [hotels count] + 1;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        return [[UIScreen mainScreen] bounds].size.height;
    }
    
    return 122.0;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    if ([hotels count] == 0 && location == nil) {
        [[[HotelAvailabilityService alloc] initWithDelegate:self] getHotelsNearby:newLocation];
    }
    location = newLocation;
    
    NSDictionary *info = [NSDictionary dictionaryWithObject:location forKey:@"location"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kLocationUpdatedNotification
                                                        object:nil
                                                      userInfo:info];
}

- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading
{
    heading = newHeading;
    
    NSDictionary *info = [NSDictionary dictionaryWithObject:heading forKey:@"heading"];
    [[NSNotificationCenter defaultCenter] postNotificationName:kHeadingUpdatedNotification
                                                        object:nil
                                                      userInfo:info];
}

#pragma mark - HotelAvailabilityServiceDelegate

- (void)didLoadHotels:(AvailableHotels *)theHotels
{
    // sort results by distance.
    hotels = [theHotels.result sortedArrayUsingComparator:^NSComparisonResult(id o1, id o2) {
        CLLocation *l1 = [(Hotel *)o1 location], *l2 = [(Hotel *)o2 location];
        
        CLLocationDistance d1 = [l1 distanceFromLocation:location];
        CLLocationDistance d2 = [l2 distanceFromLocation:location];
        return d1 < d2 ? NSOrderedAscending : d1 > d2 ? NSOrderedDescending : NSOrderedSame;
    }];
    
    // generate random gradient using ios7 theme.
    NSArray *primaryColors = [ColorUtils generateGradientColors];
    primaryGradient = [ColorUtils generateGradientFromColor:[primaryColors objectAtIndex:0]
                                                         toColor:[primaryColors objectAtIndex:1]
                                                       withSteps:[hotels count]];
    
    secondaryColors = [ColorUtils generateGradientColorsAndExclude:primaryColors];
    secondaryGradient = [ColorUtils generateGradientFromColor:[secondaryColors objectAtIndex:0]
                                                           toColor:[secondaryColors objectAtIndex:1]
                                                         withSteps:[hotels count]];
    
    // we're done.
    [_activityIndicator stopAnimating];
    [_tableView reloadData];
}

- (void)didFailLoadingHotels
{
    NSLog(@"Unable to load hotels, please check API call response.");
}

@end
