/*
 * MJPlacesFinder.m
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

#import "MJPlacesFinder.h"
#import "JSON.h"

@implementation MJPlacesFinder

@synthesize delegate, results;

//IMPORTANT: fill in your OWN API key!!
//You can generate your own key at http://code.google.com/apis/console
#define API_KEY @"<YOUR_API_KEY_HERE>"

/*
 *	Opens a URL Connection and calls the Google Places API
 *
 *  placeName: this the query
 *  center: the center coordinate around which to perform a place search
 *  radius: radius of area to search
 */
- (void)findPlacesNamed:(NSString *)placeName near:(CLLocationCoordinate2D)center withRadius:(double)radius{
    
    //check if dummy API key hasn't been replaced
    if([API_KEY isEqualToString:@"<YOUR_API_KEY_HERE>"]){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Undefined API key!" forKey:NSLocalizedDescriptionKey];
        NSError *error = [NSError errorWithDomain:@"MJPlacesFinderError" code:6 userInfo:userInfo];
        
        [delegate placesFinder:self didFailWithError:error];
    }
    
    //build url string using address query
	NSString *urlString = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/place/search/json?location=%f,%f&radius=%f&name=%@&sensor=true&key=%@", center.latitude, center.longitude, radius, placeName, API_KEY];
	
	//build request URL
	NSURL *requestURL = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    //build NSURLRequest
    NSURLRequest *geocodingRequest=[NSURLRequest requestWithURL:requestURL
                                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                timeoutInterval:60.0];
    
    //create connection and start downloading data
    NSURLConnection *connection=[[NSURLConnection alloc] initWithRequest:geocodingRequest delegate:self];
    if(connection){
        //connection valid, so init data holder
        receivedData = [[NSMutableData data] retain];
    }else{        
        //connection failed, tell delegate
        NSError *error = [NSError errorWithDomain:@"MJPlacesFinderError" code:5 userInfo:nil];
        [delegate placesFinder:self didFailWithError:error];
    }
    
}

/*
 *  Reset data when a new response is received
 */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    [receivedData setLength:0];
}


/*
 *  Append received data
 */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
    
    [connection release];
    [receivedData release];
}

/*
 *  Called when done downloading response from Google. Builds a table of AddressComponents objects
 *	and tells the delegate that it was successful or informs the delegate of a failure.
 */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	//get response
	NSString *geocodingResponse = [[NSString alloc] initWithData:receivedData encoding:NSUTF8StringEncoding];
    
    [connection release];
    [receivedData release];
    
	//result as dictionary dictionary
	NSDictionary *resultDict = [geocodingResponse JSONValue];
    [geocodingResponse release];
    
    NSLog(@"%@", resultDict);
    
    NSString *filePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/output.plist"];
    [resultDict writeToFile:filePath atomically:YES];
    
    NSString *status = [resultDict valueForKey:@"status"];
	if([status isEqualToString:@"OK"]){
        //if successful, build results array
		NSArray *foundLocations = [resultDict objectForKey:@"results"];
		results = [NSMutableArray arrayWithCapacity:[foundLocations count]];
        
        for(NSDictionary *placeResult in foundLocations){
            
            double lat = [[placeResult valueForKeyPath:@"geometry.location.lat"] doubleValue];
            double lng = [[placeResult valueForKeyPath:@"geometry.location.lng"] doubleValue];
            
            CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);

            Place *foundPlace = [[[Place alloc] initWithCoordinate:coord] autorelease];
            [foundPlace setName:[placeResult valueForKey:@"name"]];
            [foundPlace setFullAddress:[placeResult valueForKey:@"vicinity"]];
            [foundPlace setGoogleId:[placeResult valueForKey:@"id"]];
            [foundPlace setGoogleIconPath:[placeResult valueForKey:@"icon"]];
            [foundPlace setGoogleRef:[placeResult valueForKey:@"reference"]];
            [foundPlace setRating:[[placeResult valueForKey:@"rating"] doubleValue]];
            [foundPlace setTypes:[placeResult objectForKey:@"types"]];
            
            [results addObject:foundPlace];
        }
        
        [delegate placesFinder:self didFindPlaces:results];
        
    }else{
        //if status code is not OK
		NSError *error = nil;
		
		if([status isEqualToString:@"ZERO_RESULTS"])
		{
			error = [NSError errorWithDomain:@"MJPlacesFinderError" code:1 userInfo:nil];
		}
		else if([status isEqualToString:@"OVER_QUERY_LIMIT"])
		{
			error = [NSError errorWithDomain:@"MJPlacesFinderError" code:2 userInfo:nil];
		}
		else if([status isEqualToString:@"REQUEST_DENIED"])
		{
			error = [NSError errorWithDomain:@"MJPlacesFinderError" code:3 userInfo:nil];
		}
		else if([status isEqualToString:@"INVALID_REQUEST"])
		{
			error = [NSError errorWithDomain:@"MJPlacesFinderError" code:4 userInfo:nil];
		}
		
		[delegate placesFinder:self didFailWithError:error];
    }
}


@end
