//
//  Place.m
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 10/10/11.
//  Copyright (c) 2011 Mohammed Jisrawi. All rights reserved.
//

#import "Place.h"

@implementation Place

@synthesize coordinate, name, address, googleId, googleIconPath, googleRef, rating, types;

- (id)initWithCoordinate:(CLLocationCoordinate2D)c{
    self = [super init];
    if(self){
        coordinate = c;
    }
    
    return self;
}


- (NSString *)subtitle{
	return address;
}

- (NSString *)title{
	return name;
}

- (void)dealloc{
    [name release];
    [address release];
    [googleId release];
    [googleIconPath release];
    [googleRef release];
    [types release];
    [super dealloc];
}

@end
