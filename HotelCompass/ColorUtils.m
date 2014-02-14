//
//  ColorUtils.m
//  HotelCompass
//
//  Created by Diego Acosta on 2/11/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "ColorUtils.h"
#import "UIColor+iOS7Colors.h"

@implementation ColorUtils

+ (NSArray *)generateGradientColorsAndExclude:(NSArray *)excludedColors
{
    NSMutableSet *colorSet = [[NSMutableSet alloc] initWithArray:@[
        @[[UIColor iOS7blueGradientStartColor], [UIColor iOS7blueGradientEndColor]],
        @[[UIColor iOS7greenGradientStartColor], [UIColor iOS7greenGradientEndColor]],
        @[[UIColor iOS7magentaGradientStartColor], [UIColor iOS7magentaGradientEndColor]],
        @[[UIColor iOS7orangeGradientStartColor], [UIColor iOS7orangeGradientEndColor]],
        @[[UIColor iOS7redGradientStartColor], [UIColor iOS7redGradientEndColor]],
        @[[UIColor iOS7tealGradientStartColor], [UIColor iOS7tealGradientEndColor]],
        @[[UIColor iOS7violetGradientStartColor], [UIColor iOS7violetGradientEndColor]],
        @[[UIColor iOS7yellowGradientStartColor], [UIColor iOS7yellowGradientEndColor]]]
    ];
    
    if (excludedColors != nil) {
        [colorSet removeObject:excludedColors];
    }
    
    return [[colorSet allObjects] objectAtIndex:arc4random() % [colorSet count]];
}

+ (NSArray *)generateGradientColors {
    return [self generateGradientColorsAndExclude:nil];
}

/*
 *  http://stackoverflow.com/questions/15032562/ios-find-color-at-point-between-two-colors
 */
+ (NSArray *)generateGradientFromColor:(UIColor *)fromColor
                               toColor:(UIColor *)toColor
                             withSteps:(NSInteger)steps {
    
    CGFloat tmpImageWidth = 512.0f; // make this bigger or smaller if you need more or less resolution (number of different colors).
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a gradient
    NSArray *colors = @[(__bridge id) fromColor.CGColor, (__bridge id) toColor.CGColor];
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, NULL);
    CGPoint startPoint = CGPointMake(0, 0);
    CGPoint endPoint = CGPointMake(tmpImageWidth, 0);
    
    // create a bitmap context to draw the gradient to, 1 pixel high.
    CGContextRef context = CGBitmapContextCreate(NULL, tmpImageWidth, 1, 8, 0, colorSpace,
                                                 kCGBitmapAlphaInfoMask & kCGImageAlphaPremultipliedLast);
    
    // draw the gradient into it
    CGContextAddRect(context, CGRectMake(0, 0, tmpImageWidth, 1));
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    
    // Get our RGB bytes into a buffer with a couple of intermediate steps...
    //      CGImageRef -> CFDataRef -> byte array
    CGImageRef cgImage = CGBitmapContextCreateImage(context);
    CGDataProviderRef provider = CGImageGetDataProvider(cgImage);
    CFDataRef pixelData = CGDataProviderCopyData(provider);
    
    // cleanup:
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgImage);
    CGContextRelease(context);
    
    const UInt8* data = CFDataGetBytePtr(pixelData);
    
    // we got all the data we need.
    // bytes in the data buffer are a succession of R G B A bytes
    
    NSMutableArray * theColors = [NSMutableArray array];
    
    // For instance, the color of the point 27% in our gradient is:
    for (int i = 0; i < steps; i++) {
        CGFloat x = tmpImageWidth * (i / (float)steps);
        int pixelIndex = (int)x * 4; // 4 bytes per color
        UIColor *color = [UIColor colorWithRed:data[pixelIndex + 0]/255.0f
                                         green:data[pixelIndex + 1]/255.0f
                                          blue:data[pixelIndex + 2]/255.0f
                                         alpha:data[pixelIndex + 3]/255.0f];
        [theColors addObject:color];
    }
    
    // done fetching color data, finally release the buffer
    CGDataProviderRelease(provider);
    
    return theColors;
}

@end
