//
//  Place.h
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 10/10/11.
//  Copyright (c) 2011 Mohammed Jisrawi. All rights reserved.
//

#import "Address.h"

@interface Place : Address {
    NSString *googleId;
    NSString *googleIconPath;
    NSString *googleRef;
    double rating;
    NSArray *types;
}

@property (nonatomic, retain) NSString *googleId;
@property (nonatomic, retain) NSString *googleIconPath;
@property (nonatomic, retain) NSString *googleRef;
@property (nonatomic, readwrite) double rating;
@property (nonatomic, retain) NSArray *types;

@end
