//
//  CompassView.h
//  HotelCompass
//
//  Created by Diego Acosta on 1/24/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompassView : UIView {
    CGPoint center;
    float width, height;
}

@property(nonatomic, strong) UIColor *schemeColor;

@end
