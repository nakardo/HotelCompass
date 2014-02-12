//
//  ColorUtils.h
//  HotelCompass
//
//  Created by Diego Acosta on 2/11/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ColorUtils : NSObject

+ (NSArray *)generateGradientFromColor:(UIColor *)fromColor toColor:(UIColor *)toColor withSteps:(NSInteger)steps;

@end
