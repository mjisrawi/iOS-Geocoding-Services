###iOS Geocoding Services 
A suite of Objective-C hooks for Google's location APIs.

- MJGeocoder: uses the Google Gecoding API to search for addresses and translate them into latitude and longitude coordinates.
- MJReverseGeocoder: uses the Google Reverse Geocoding API to translate latitude and longitude into a readable address.
- MJPlacesFinder: searches the Google Places for businesses that match a given query. (requires a Google dev API key which can be generated here: <http://code.google.com/apis/console>)


###Why
- Provides forward geocoding in iOS versions before 5.0.
- Provides Google places search
- Also previously: to avoid a long-standing, random failure condition in MKReverseGeocoder, possibly due to usage of old APIs, or hitting a usage limit imposed by Google. A google search will bring up many documented cases of the issue, such as...

	- "MKErrorDomain error 4 iPhone" - Stack Overflow
<http://stackoverflow.com/questions/3926164/mkerrordomain-error-4-iphone>

	- "MKReverseGeoCoder error 4" - iPhone Dev SDK Forum
<http://www.iphonedevsdk.com/forum/iphone-sdk-development/63047-mkreversegeocoder-error-4-a.html>


###License
Everything is released under the BSD License, all code is free to use in any projects (check out the files for more details)



###Other Notes
- Any comments regarding the services, suggestions, notes on bugs or comments on the MKReverseGeocoder failure issue are welcome. 

- The services rely on the open source Objective-C JSON framework (<http://code.google.com/p/json-framework/>) it's only been tested with the version included with the project. 