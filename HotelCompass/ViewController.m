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
#import "UIImage+animatedGIF.h"

@interface ViewController ()

@property(nonatomic, strong) CLLocationManager *locationManager;
@property(nonatomic, strong) CLLocation *location;
@property(nonatomic, strong) CLHeading *heading;
@property(nonatomic, strong) NSArray *hotels;
@property(nonatomic, strong) NSArray *primaryColors;
@property(nonatomic, strong) NSArray *primaryGradient;
@property(nonatomic, strong) NSArray *secondaryColors;
@property(nonatomic, strong) NSArray *secondaryGradient;
@property(nonatomic, strong) UIView *nyanView;

@end

@implementation ViewController

#pragma mark - Private

- (void)startUpdatingLocation
{
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
    [cell setPrimaryColor:[primaryGradient objectAtIndex:row]
        andSecondaryColor:[secondaryGradient objectAtIndex:row]];
    cell.backgroundColor = [primaryGradient objectAtIndex:row];
    
    // secondary colors.
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds];
    cell.selectedBackgroundView.backgroundColor = [secondaryGradient objectAtIndex:row];
}

- (void)performRowsAnimation
{
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    
    // generate temporary secondary colors to keep animation consistent.
    NSArray *tmpSecondaryColors = [ColorUtils generateGradientColorsAndExclude:_secondaryColors];
    NSArray *tmpSecondaryGradient = [ColorUtils generateGradientFromColor:[_secondaryColors objectAtIndex:0]
                                                                  toColor:[_secondaryColors objectAtIndex:1]
                                                                withSteps:[_hotels count]];
    
    // set new color for selected row, and remove selection inmediately.
    HotelCell *selectedCell = (HotelCell *)[_tableView cellForRowAtIndexPath:indexPath];
    [self updateRow:selectedCell atPosition:indexPath.row - 1
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
        if (indexPath.row + i < [_hotels count] + 1) {
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
                                                withPrimaryGradient:_secondaryGradient
                                               andSecondaryGradient:tmpSecondaryGradient];
                             }
                             
                             if (bottomCell != nil) {
                                 [self updateRow:bottomCell atPosition:indexPath.row - 1 + i
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

- (void)didPressGithubButton
{
    NSURL *url = [NSURL URLWithString:@"https://github.com/dmacosta/HotelCompass"];
    [[UIApplication sharedApplication] openURL:url];
}

- (UIView *)createNyanView
{
    NSURL *imageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nyan_cat" ofType:@"gif"]];
    UIImage *nyanImage = [UIImage animatedImageWithAnimatedGIFURL:imageURL];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:nyanImage];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 48, screenSize.width, screenSize.height)];
    [containerView addSubview:imageView];
    
    return containerView;
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
    
    self.hotels = [NSArray array];
    
    // nyan nyan nyan.
    self.nyanView = [self createNyanView];
    [_tableView setContentInset:UIEdgeInsetsMake(-[UIScreen mainScreen].bounds.size.height, 0, 0, 0)];
    
    // setup layout.
    _tableView.backgroundView = nil;
    _tableView.backgroundColor = [UIColor blackColor];
    _tableView.separatorColor = [UIColor blackColor];
    
    [self startUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    if ([_hotels count] > 0) [self performRowsAnimation];
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
    controller.hotel = [_hotels objectAtIndex:row];
    controller.primaryColor = [_primaryGradient objectAtIndex:row];
    controller.secondaryColor = [_secondaryGradient objectAtIndex:row];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if (indexPath.row == 0) {
        UITableViewCell *nyanCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                                           reuseIdentifier:nil];
        nyanCell.backgroundColor = [UIColor clearColor];
        [nyanCell addSubview:_nyanView];
        
        cell = nyanCell;
    } else {
        HotelCell *hotelCell = [tableView dequeueReusableCellWithIdentifier:@"HotelCell"];
        
        NSUInteger row = indexPath.row - 1;
        
        // content.
        hotelCell.hotel = [_hotels objectAtIndex:row];
        hotelCell.location = _location;
        hotelCell.heading = _heading;
        
        // update colors.
        [self updateRow:hotelCell atPosition:row
                         withPrimaryGradient:_primaryGradient
                        andSecondaryGradient:_secondaryGradient];
        
        cell = hotelCell;
    }
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_hotels count] + 1;
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
