//
//  Place.h
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 10/10/11.
//  Copyright (c) 2011 Mohammed Jisrawi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Place : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *name;
    NSString *address;
    NSString *googleId;
    NSString *googleIconPath;
    NSString *googleRef;
    double rating;
    NSArray *types;
}

@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *googleId;
@property (nonatomic, retain) NSString *googleIconPath;
@property (nonatomic, retain) NSString *googleRef;
@property (nonatomic, readwrite) double rating;
@property (nonatomic, retain) NSArray *types;


- (id)initWithCoordinate:(CLLocationCoordinate2D)c;

@end
