//
//  iPhoneGeocodingServicesViewController.m
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 2/27/11.
//  Copyright 2011 Mohammed Jisrawi. All rights reserved.
//

#import "iPhoneGeocodingServicesViewController.h"

@implementation iPhoneGeocodingServicesViewController

@synthesize locationManager, reverseGeocoder, forwardGeocoder;
@synthesize currentLocationLabel, foundCoordinates, addressSearchField, addressSearchButton;


#pragma mark view lifecycle & actions

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
}

/*
 * handle find button taps
 */
- (IBAction)findLocation:(id)sender{
	//hide keyboard
	[addressSearchField resignFirstResponder];
	
	//if reverse geocoder is not initialized, initilize it 
	if(!forwardGeocoder){
		forwardGeocoder = [[MJGeocoder alloc] init];
		forwardGeocoder.delegate = self;
	}
	
	//show network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	[forwardGeocoder findLocationsWithAddress:addressSearchField.text title:nil];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
	//show network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
	
	//reverse-geocode location
	reverseGeocoder = [[MJReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate];
	reverseGeocoder.delegate = self;
	[reverseGeocoder start];
}


- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
	currentLocationLabel.text = @"Failed to find location!";
}


#pragma mark -
#pragma mark MJReverseGeocoderDelegate

- (void)reverseGeocoder:(MJReverseGeocoder *)geocoder didFindAddress:(AddressComponents *)addressComponents{
	//hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	currentLocationLabel.text = [NSString stringWithFormat:@"%@ %@, %@, %@", 
								 addressComponents.streetNumber, 
								 addressComponents.route,
								 addressComponents.city,
								 addressComponents.stateCode];
}


- (void)reverseGeocoder:(MJReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
	//show network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	currentLocationLabel.text = @"Couldn't reverse geocode coordinate!";
}


#pragma mark -
#pragma mark MJGeocoderDelegate

- (void)geocoder:(MJGeocoder *)geocoder didFindLocations:(NSArray *)locations{
	//hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	//get first found location, just for demonstration
	AddressComponents *foundLocation = [locations objectAtIndex:0];
	
	NSString *result = [NSString stringWithFormat:@"%f, %f & %d more", 
						foundLocation.coordinate.longitude, 
						foundLocation.coordinate.latitude,
						[locations count]];

	if([foundCoordinates.text isEqualToString:@"No locations found yet"]){
		foundCoordinates.text = result;
	}else{
		foundCoordinates.text = [foundCoordinates.text stringByAppendingFormat:@"\n%@", result];
	}
}

- (void)geocoder:(MJGeocoder *)geocoder didFailWithError:(NSError *)error{
	if([foundCoordinates.text isEqualToString:@"No locations found yet"]){
		foundCoordinates.text = @"Couldn't geocode location!";
	}else{
		foundCoordinates.text = [foundCoordinates.text stringByAppendingString:@"\nCouldn't geocode location!"];
	}
}


#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[locationManager release];
	[reverseGeocoder release];
	[forwardGeocoder release];
	[currentLocationLabel release];
	[foundCoordinates release];
	[addressSearchField release];
	[addressSearchButton release];
    [super dealloc];
}

@end
