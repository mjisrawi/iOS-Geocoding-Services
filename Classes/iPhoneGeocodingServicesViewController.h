//
//  iPhoneGeocodingServicesViewController.h
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 2/27/11.
//  Copyright 2011 Mohammed Jisrawi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "GeocodingServices.h"

@interface iPhoneGeocodingServicesViewController : UIViewController <CLLocationManagerDelegate, MJReverseGeocoderDelegate, MJGeocoderDelegate>{
	CLLocationManager *locationManager;
	MJReverseGeocoder *reverseGeocoder;
	MJGeocoder *forwardGeocoder;
	
	UILabel *currentLocationLabel;
	UITextView *foundCoordinates;
	UITextField *addressSearchField;
	UIButton *addressSearchButton;
}

@property(nonatomic, retain) CLLocationManager *locationManager;
@property(nonatomic, retain) MJReverseGeocoder *reverseGeocoder;
@property(nonatomic, retain) MJGeocoder *forwardGeocoder;

@property(nonatomic, retain) IBOutlet UILabel *currentLocationLabel;
@property(nonatomic, retain) IBOutlet UITextView *foundCoordinates;
@property(nonatomic, retain) IBOutlet UITextField *addressSearchField;
@property(nonatomic, retain) IBOutlet UIButton *addressSearchButton;

- (IBAction)findLocation:(id)sender;

@end

