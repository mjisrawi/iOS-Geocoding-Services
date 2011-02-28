/*
 * MJReverseGeocoder.m
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


#import "MJReverseGeocoder.h"
#import "JSON.h"

@implementation MJReverseGeocoder

@synthesize coordinate, delegate;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord{	
	if(self = [[MJReverseGeocoder alloc] init]){
		coordinate = coord;
	}
	return self;
}

/*
 *	Calls Google's JSON Reverse Geocoding Service, builds a resulting AddressComponents object
 *	and tells the delegate that it was successful or informs the delegate of a failure.
 */
- (void)start{
	NSString *urlString = [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/geocode/json?latlng=%f,%f&sensor=true",
						   coordinate.latitude, coordinate.longitude];
	
	//build request URL
	NSURL *requestURL = [NSURL URLWithString:urlString];
	
	//get response
	NSString *geocodingResponse = [NSString stringWithContentsOfURL:requestURL encoding:NSUTF8StringEncoding error:nil];
	
	//result as dictionary dictionary
	NSDictionary *resultDict = [geocodingResponse JSONValue];
	
	NSString *status = [resultDict valueForKey:@"status"];
	if([status isEqualToString:@"OK"]){
		//if successful
		//get first element as array
		NSArray *firstResultAddress = [[[resultDict objectForKey:@"results"] objectAtIndex:0] objectForKey:@"address_components"];
		
		AddressComponents *resultAddress = [[[AddressComponents alloc] init] autorelease];
		resultAddress.streetNumber = [AddressComponents addressComponent:@"street_number" inAddressArray:firstResultAddress ofType:@"long_name"];
		resultAddress.route = [AddressComponents addressComponent:@"route" inAddressArray:firstResultAddress ofType:@"long_name"];
		resultAddress.city = [AddressComponents addressComponent:@"locality" inAddressArray:firstResultAddress ofType:@"long_name"];
		resultAddress.stateCode = [AddressComponents addressComponent:@"administrative_area_level_1" inAddressArray:firstResultAddress ofType:@"short_name"];
		resultAddress.postalCode = [AddressComponents addressComponent:@"postal_code" inAddressArray:firstResultAddress ofType:@"short_name"];
		resultAddress.countryName = [AddressComponents addressComponent:@"country" inAddressArray:firstResultAddress ofType:@"long_name"];
		
		[delegate reverseGeocoder:self didFindAddress:resultAddress];
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
		
		[delegate reverseGeocoder:self didFailWithError:error];
	}
}


@end
