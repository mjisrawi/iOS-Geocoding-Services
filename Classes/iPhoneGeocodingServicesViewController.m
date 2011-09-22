/*
 *  iPhoneGeocodingServicesViewController.m
 *
 *
	Copyright (c) 2011, Mohammed Jisrawi
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	* Redistributions of source code must retain the above copyright
	  notice, this list of conditions and the following disclaimer.

	* Redistributions in binary form must reproduce the above copyright
	  notice, this list of conditions and the following disclaimer in the
	  documentation and/or other materials provided with the distribution.

	* Neither the name of the Mohammed Jisrawi nor the
	  names of its contributors may be used to endorse or promote products
	  derived from this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
	ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
	WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL MOHAMMED JISRAWI BE LIABLE FOR ANY
	DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
	(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
	LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
	ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
	(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
	SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 */


#import "iPhoneGeocodingServicesViewController.h"

@implementation iPhoneGeocodingServicesViewController

@synthesize locationManager, reverseGeocoder, forwardGeocoder;
@synthesize currentLocationLabel, foundCoordinates, addressSearchField, addressSearchButton;


#pragma mark view lifecycle & actions

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.locationManager = [[CLLocationManager alloc] init];
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
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
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
