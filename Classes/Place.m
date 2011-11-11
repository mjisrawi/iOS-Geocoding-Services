//
//  Place.m
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 10/10/11.
//  Copyright (c) 2011 Mohammed Jisrawi. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize googleId, googleIconPath, googleRef, rating, types;

- (void)dealloc{
    [googleId release];
    [googleIconPath release];
    [googleRef release];
    [types release];
    [super dealloc];
}

@end
