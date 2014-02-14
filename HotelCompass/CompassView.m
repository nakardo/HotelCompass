//
//  CompassView.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "CompassView.h"
#import "Colours.h"

static const float kCenterOffset = .25;
static const int kBackgroundOffset = 2;

@implementation CompassView

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        self.opaque = YES;
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}

#pragma mark - Private

- (void)drawCompassBackground:(CGRect)rect withColor:(UIColor *)color
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    const CGFloat *comp = CGColorGetComponents(color.CGColor);
    
    CGContextAddArc(ctx, center.x, center.y, width / 2, 0, 30, 0);
    CGContextSetRGBFillColor(ctx, comp[0], comp[1], comp[2], comp[3]);
    CGContextDrawPath(ctx, kCGPathFill);
}

- (void)drawArrowBackground:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, center.x - center.x * kCenterOffset, center.y);
    CGContextAddLineToPoint(ctx, center.x, 0);
    CGContextAddLineToPoint(ctx, center.x + center.x * kCenterOffset, center.y);
    CGContextAddLineToPoint(ctx, center.x, height);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    CGContextFillPath(ctx);
}

- (void)drawArrow:(CGRect)rect fromCenter:(float)distance withColor:(UIColor *)color
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    const CGFloat *comp = CGColorGetComponents(color.CGColor);
    
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, distance, center.y);
    CGContextAddLineToPoint(ctx, center.x, center.y);
    CGContextAddLineToPoint(ctx, center.x, kBackgroundOffset * 3);
    CGContextSetRGBFillColor(ctx, comp[0], comp[1], comp[2], comp[3]);
    CGContextFillPath(ctx);
}

#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // calculate center once.
    center = CGPointMake(CGRectGetWidth(rect) / 2, CGRectGetHeight(rect) / 2);
    width = CGRectGetWidth(rect), height = CGRectGetHeight(rect);
    
    // create colors from scheme.
    NSArray *colors = [_schemeColor colorSchemeOfType:ColorSchemeAnalagous];
    
    // draw.
    [self drawCompassBackground:rect withColor:[colors objectAtIndex:2]];
    [self drawArrowBackground:rect];
    [self drawArrow:rect fromCenter:center.x - (center.x * kCenterOffset) + kBackgroundOffset
          withColor:[colors objectAtIndex:0]];
    [self drawArrow:rect fromCenter:center.x + (center.x * kCenterOffset) - kBackgroundOffset
          withColor:[colors objectAtIndex:1]];
    
    // compass dark circle.
    CGContextAddArc(ctx, center.x, center.y, center.x * kCenterOffset * .55, 0, 30, 0);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 1);
    CGContextDrawPath(ctx, kCGPathFill);
    
    // compass white circle.
    CGContextAddArc(ctx, center.x, center.y, center.x * kCenterOffset * .40, 0, 30, 0);
    CGContextSetRGBFillColor(ctx, 1, 1, 1, 1);
    CGContextDrawPath(ctx, kCGPathFill);
}

@end
