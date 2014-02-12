//
//  BaseJSONModel.m
//  HotelCompass
//
//  Created by Diego Acosta on 1/26/14.
//  Copyright (c) 2014 Diego Acosta. All rights reserved.
//

#import "BaseJSONModel.h"

@implementation BaseJSONModel

+ (BOOL)propertyIsOptional:(NSString *)propertyName
{
    return YES;
}

+ (JSONKeyMapper *)keyMapper
{
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

@end
