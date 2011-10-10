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

@interface iPhoneGeocodingServicesViewController()
- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath;
@end

@implementation iPhoneGeocodingServicesViewController

@synthesize locationManager, reverseGeocoder, forwardGeocoder, placesfinder;
@synthesize searchBar, displayedResults;


#pragma mark view lifecycle & actions

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.locationManager = [[CLLocationManager alloc] init];
	locationManager.delegate = self;
	[locationManager startUpdatingLocation];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGRect rect = searchBar.frame;
    rect.origin.y = MIN(0, scrollView.contentOffset.y);
    searchBar.frame = rect;
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [displayedResults count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
    }
    
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath{
    if([[displayedResults objectAtIndex:indexPath.row] isKindOfClass:[AddressComponents class]]){
        AddressComponents *object = [displayedResults objectAtIndex:indexPath.row];
        cell.textLabel.text = object.fullAddress;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", object.coordinate.latitude, object.coordinate.longitude];
    }else{
        Place *object = [displayedResults objectAtIndex:indexPath.row];
        cell.textLabel.text = object.name;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%f, %f", object.coordinate.latitude, object.coordinate.longitude];
    }
}


#pragma mark -
#pragma mark UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar{
    //hide keyboard
    [searchBar resignFirstResponder];
    
    if(theSearchBar.selectedScopeButtonIndex == 0){
        //if reverse geocoder is not initialized, initilize it 
        if(!forwardGeocoder){
            forwardGeocoder = [[MJGeocoder alloc] init];
            forwardGeocoder.delegate = self;
        }
        
        //show network indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [forwardGeocoder findLocationsWithAddress:theSearchBar.text title:nil];
    }else{
        //init places finder if it's nil
        if(!placesfinder){
            placesfinder = [[MJPlacesFinder alloc] init];
            placesfinder.delegate = self;
        }
        
        //show network indicator
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [placesfinder findPlacesNamed:theSearchBar.text near:locationManager.location.coordinate withRadius:1000.0];
    }
}


- (void)searchBarCancelButtonClicked:(UISearchBar *)theSearchBar{
    [theSearchBar resignFirstResponder];
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
	searchBar.prompt = @"Failed to find location!";
}


#pragma mark -
#pragma mark MJReverseGeocoderDelegate

- (void)reverseGeocoder:(MJReverseGeocoder *)geocoder didFindAddress:(AddressComponents *)addressComponents{
	//hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	searchBar.prompt = [NSString stringWithFormat:@"Current Location: %@ %@, %@, %@", 
								 addressComponents.streetNumber, 
								 addressComponents.route,
								 addressComponents.city,
								 addressComponents.stateCode];
}


- (void)reverseGeocoder:(MJReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
	//show network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	searchBar.prompt = @"Couldn't reverse geocode coordinate!";
}


#pragma mark -
#pragma mark MJGeocoderDelegate

- (void)geocoder:(MJGeocoder *)geocoder didFindLocations:(NSArray *)locations{
	//hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
    [displayedResults release];
    displayedResults = [locations retain];
    
    [self.tableView reloadData];
}

- (void)geocoder:(MJGeocoder *)geocoder didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"ERROR");
}


#pragma mark -
#pragma mark MJGeocoderDelegate

- (void)placesFinder:(MJPlacesFinder *)placesFinder didFindPlaces:(NSArray *)places{
    //hide network indicator
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
    [displayedResults release];
    displayedResults = [places retain];
    
    [self.tableView reloadData];
}

- (void)placesFinder:(MJPlacesFinder *)placesFinder didFailWithError:(NSError *)error{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
    NSLog(@"ERROR");
}

#pragma mark -
#pragma mark dealloc

- (void)dealloc {
	[locationManager release];
	[reverseGeocoder release];
	[forwardGeocoder release];
    [searchBar release];
    [displayedResults release];
    [super dealloc];
}

@end
