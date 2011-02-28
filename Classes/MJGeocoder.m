/*
 * MJGeocoder.m
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

#import "MJGeocoder.h"
#import "JSON.h"

@implementation MJGeocoder

@synthesize delegate, results;

/*
 *	Calls Google's JSON Geocoding Service, builds a table of AddressComponents objects,
 *	and tells the delegate that it was successful or informs the delegate of a failure.
 *
 *  address: address to geocode
 *  title: custom title for location (useful for passing an annotation title on through the AddressComponents object)
 */
- (void)findLocationsWithAddress:(NSString *)address title:(NSString *)title{
	//build url string using address query
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?address=%@&sensor=true", address];
	
	//build request URL
	NSURL *requestURL = [[NSURL alloc] initWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	//get response
	NSString *geocodingResponse = [NSString stringWithContentsOfURL:requestURL encoding:NSUTF8StringEncoding error:nil];
	
	//result as dictionary dictionary
	NSDictionary *resultDict = [geocodingResponse JSONValue];
	
	NSString *status = [resultDict valueForKey:@"status"];
	if([status isEqualToString:@"OK"]){
		//if successful, build results array
		NSArray *foundLocations = [resultDict objectForKey:@"results"];
		results = [NSMutableArray arrayWithCapacity:[foundLocations count]];
		
		[foundLocations enumerateObjectsUsingBlock:^(id location, NSUInteger index, BOOL *stop) {
			NSArray *firstResultAddress = [location objectForKey:@"address_components"];
			
			AddressComponents *resultAddress = [[[AddressComponents alloc] init] autorelease];
			resultAddress.title = title;
			resultAddress.fullAddress = [location valueForKey:@"formatted_address"];
			resultAddress.streetNumber = [AddressComponents addressComponent:@"street_number" inAddressArray:firstResultAddress ofType:@"long_name"];
			resultAddress.route = [AddressComponents addressComponent:@"route" inAddressArray:firstResultAddress ofType:@"long_name"];
			resultAddress.city = [AddressComponents addressComponent:@"locality" inAddressArray:firstResultAddress ofType:@"long_name"];
			resultAddress.stateCode = [AddressComponents addressComponent:@"administrative_area_level_1" inAddressArray:firstResultAddress ofType:@"short_name"];
			resultAddress.postalCode = [AddressComponents addressComponent:@"postal_code" inAddressArray:firstResultAddress ofType:@"short_name"];
			resultAddress.countryName = [AddressComponents addressComponent:@"country" inAddressArray:firstResultAddress ofType:@"long_name"];
			
			resultAddress.coordinate = 
			CLLocationCoordinate2DMake([[[[location objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lat"] doubleValue],
									   [[[[location objectForKey:@"geometry"] objectForKey:@"location"] valueForKey:@"lng"] doubleValue]);
			
			[results addObject:resultAddress];
		}];
		
		[delegate geocoder:self didFindLocations:results];
	}else{
		//if status code is not OK
		NSError *error;
		
		if([status isEqualToString:@"ZERO_RESULTS"])
		{
			error = [NSError errorWithDomain:@"MJGeocoderError" code:1 userInfo:nil];
		}
		else if([status isEqualToString:@"OVER_QUERY_LIMIT"])
		{
			error = [NSError errorWithDomain:@"MJGeocoderError" code:2 userInfo:nil];
		}
		else if([status isEqualToString:@"REQUEST_DENIED"])
		{
			error = [NSError errorWithDomain:@"MJGeocoderError" code:3 userInfo:nil];
		}
		else if([status isEqualToString:@"INVALID_REQUEST"])
		{
			error = [NSError errorWithDomain:@"MJGeocoderError" code:4 userInfo:nil];
		}
		
		[delegate geocoder:self didFailWithError:error];
	}
}


@end
