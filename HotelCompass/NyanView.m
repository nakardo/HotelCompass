//
//  NyanView.m
//  HotelCompass
//
//  Created by Diego Acosta on 2/15/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "NyanView.h"
#import "UIImage+animatedGIF.h"

@implementation NyanView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        NSURL *imageURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"nyan_cat" ofType:@"gif"]];
        UIImage *nyanImage = [UIImage animatedImageWithAnimatedGIFURL:imageURL];
        
        UIImageView *imageView = [[UIImageView alloc] initWithImage:nyanImage];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [self addSubview:imageView];
    }
    
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor *midnightColor = [UIColor colorWithRed:0 green:51/255.0 blue:102/255.0 alpha:1.0];
    NSArray *gradientColors = [NSArray arrayWithObjects:(id)midnightColor.CGColor, [UIColor blackColor].CGColor, nil];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) gradientColors, NULL);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect) - 22);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
