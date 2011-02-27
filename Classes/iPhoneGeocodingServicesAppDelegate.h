//
//  iPhoneGeocodingServicesAppDelegate.h
//  iPhoneGeocodingServices
//
//  Created by Mohammed Jisrawi on 2/27/11.
//  Copyright 2011 Mohammed Jisrawi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iPhoneGeocodingServicesViewController;

@interface iPhoneGeocodingServicesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iPhoneGeocodingServicesViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iPhoneGeocodingServicesViewController *viewController;

@end

