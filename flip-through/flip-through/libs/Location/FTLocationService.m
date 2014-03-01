//
//  FTLocationService.m
//  FT
//
//  Created by Javier Fuchs on 1/11/11.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import "FTLocationService.h"

#import "CLLocation (Strings).h"

NSString* kFTLocationServiceNotification = @"FTLocationServiceNotification";


@implementation FTLocationService
{
    CLLocationManager *_locationManager;
    CLLocation* _currentLocation;
    CLPlacemark* _currentPlacemark;

}

+ (FTLocationService *) sharedInstance
{
    static FTLocationService *_sharedInstance = nil;
    
    @synchronized (self)
    {
        if (_sharedInstance == nil)
        {
            _sharedInstance = [[self alloc] init];
        }
    }
    
    FTAssert(_sharedInstance != nil);
    
    return _sharedInstance;
}


- (id)init
{
    self = [super init];
    if (self) {
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = 60.0f; // update every 200ft
        [_locationManager startUpdatingLocation];
    }
    return self;
}


- (void)start
{
    FTAssert(_locationManager != nil);
    if ([CLLocationManager locationServicesEnabled])
    {
        [_locationManager startUpdatingLocation];
    }
}

- (void)stop
{
    FTAssert(_locationManager != nil);
    [_locationManager stopUpdatingLocation];
}

- (void)restart
{
    [self stop];
    [self start];
}

- (void)reverseGeocodeLocation:(CLLocation *)location
                 notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                  finishBlock:(void (^)(CLLocation* location, CLPlacemark *placemark))finishBlock
{
    FTAssert(location && [location isKindOfClass:[CLLocation class]]);

    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            if (notFoundBlock)
            {
                notFoundBlock(error.localizedDescription);
            }
            return;
        }
        
        if (!placemarks.count)
        {
            if (notFoundBlock)
            {
                notFoundBlock(@"Not placemark found");
            }
            return;
        }
        
        FTLog(@"Received placemarks: %@", placemarks);
        
        
        FTAssert(placemarks[0] && [placemarks[0] isKindOfClass:[CLPlacemark class]]);
        finishBlock(location, placemarks[0]);
        
    }];
}

- (void)reverseGeocodeLocation:(CLLocation *)location
                 notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                  successBlock:(void (^)())successBlock
{
    
    [self reverseGeocodeLocation:location notFoundBlock:notFoundBlock finishBlock:^(CLLocation *location, CLPlacemark *placemark) {
        FTAssert(location && [location isKindOfClass:[CLLocation class]]);
        _currentLocation = location;
        FTAssert(placemark && [placemark isKindOfClass:[CLPlacemark class]]);
        _currentPlacemark = placemark;
        
        if (successBlock)
        {
            successBlock();
        }
    }];
}


- (void)obtainPlacemarkAndDistanceWithLocation:(CLLocation *)location finishBlock:(void (^)(CLPlacemark *placemark, NSNumber *distance))finishBlock
{
    [self reverseGeocodeLocation:location notFoundBlock:^(NSString *errorMessage) {
        finishBlock(nil, nil);
    } finishBlock:^(CLLocation *location, CLPlacemark *placemark) {
        FTAssert(location && [location isKindOfClass:[CLLocation class]]);
        FTAssert(placemark && [placemark isKindOfClass:[CLPlacemark class]]);

        CLLocationDistance distanceFromCurrentLocation = [location distanceFromLocation:self.currentLocation];
        NSNumber *distance = [NSNumber numberWithDouble:distanceFromCurrentLocation];
        finishBlock(placemark, distance);
    }];
}





- (void)updateLocation:(CLLocation *)location
                         notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                          successBlock:(void (^)())successBlock
{
    
    [self reverseGeocodeLocation:location notFoundBlock:notFoundBlock successBlock:successBlock];
    
}

- (void)updateLocationWithCoordinate2D:(CLLocationCoordinate2D)coordinate
                         notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                          successBlock:(void (^)())successBlock
{
        
    CLLocation* location = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    [self updateLocation:location notFoundBlock:notFoundBlock successBlock:successBlock];

}

- (void)updateLocationWithAddressString:(NSString *)addressString
                          notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                           successBlock:(void (^)())successBlock
{
    
    FTAssert(addressString != nil && [addressString length] > 0);
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder geocodeAddressString:addressString completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error){
            notFoundBlock(error.localizedDescription);
            return;
        }

        if (!placemarks.count)
        {
            notFoundBlock(@"Not placemark found");
            return;
        }
        
        FTLog(@"Received placemarks: %@", placemarks);
        CLPlacemark* placemark = placemarks[0];
        
        [self stop];

        _currentLocation = placemark.location;
        _currentPlacemark = placemark;
        
        successBlock();
        
    }];
    
}


#pragma mark CLLocationManagerDelegate methods

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    [self updateLocation:newLocation notFoundBlock:nil successBlock:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:kFTLocationServiceNotification object:nil];
    }];
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    FTLog(@"error = %@", [error localizedDescription]);
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    FTLog(@"Auth status = %d", status);
    [self restart];
}


- (NSString *)localizedDescription:(BOOL)usingGPS
{
    FTLog(@"%@", [self description]);
    NSMutableString* string = [NSMutableString string];
    

    if (usingGPS)
    {
        if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusNotDetermined)
        {
            [string appendString:@"Location services authorization not determined. "];
        }
        else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusRestricted)
        {
            [string appendString:@"Not authorized to use location services. "];
        }
        else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusDenied)
        {
            [string appendString:@"Denied authorization to use location services. "];
        }
        else if (CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized)
        {
            FTLog(@"OK authorization to use location services");
        }
    }
    
    if (_currentLocation)
    {
        [string appendString:_currentLocation.localizedCoordinateString];

        if (_currentPlacemark)
        {
            [string appendString:@" - "];

            if (_currentPlacemark.name)
            {
                [string appendFormat:@" %@,", _currentPlacemark.name];
            }
            if (_currentPlacemark.thoroughfare)
            {
                [string appendFormat:@" %@,", _currentPlacemark.thoroughfare];
            }
            if (_currentPlacemark.locality)
            {
                [string appendFormat:@" %@", _currentPlacemark.locality];
            }
            if (_currentPlacemark.administrativeArea)
            {
                [string appendFormat:@" %@", _currentPlacemark.administrativeArea];
            }
            if (_currentPlacemark.postalCode)
            {
                [string appendFormat:@" (%@)", _currentPlacemark.postalCode];
            }
            if (_currentPlacemark.ISOcountryCode)
            {
                [string appendFormat:@" %@", _currentPlacemark.ISOcountryCode];
            }
            if (_currentPlacemark.inlandWater)
            {
                [string appendFormat:@" %@", _currentPlacemark.inlandWater];
            }
            if (_currentPlacemark.ocean)
            {
                [string appendFormat:@" %@", _currentPlacemark.ocean];
            }
        }

        if (usingGPS && CLLocationManager.authorizationStatus == kCLAuthorizationStatusAuthorized)
        {
            [string appendFormat:@" (min distance filter = %1.1f km)", _locationManager.distanceFilter/1000.0f];
        }
    }
    else
    {
        [string appendString:@"NO GPS"];
    }
    
    
    return string;
}


- (NSString *)fullAddress
{
    NSMutableString* string = [NSMutableString string];
    
    if (_currentLocation && _currentPlacemark)
    {            
        if (_currentPlacemark.name)
        {
            [string appendFormat:@" %@,", _currentPlacemark.name];
        }
        if (_currentPlacemark.thoroughfare)
        {
            [string appendFormat:@" %@,", _currentPlacemark.thoroughfare];
        }
        if (_currentPlacemark.locality)
        {
            [string appendFormat:@" %@", _currentPlacemark.locality];
        }
        if (_currentPlacemark.administrativeArea)
        {
            [string appendFormat:@" %@", _currentPlacemark.administrativeArea];
        }
        if (_currentPlacemark.postalCode)
        {
            [string appendFormat:@" (%@)", _currentPlacemark.postalCode];
        }
        if (_currentPlacemark.ISOcountryCode)
        {
            [string appendFormat:@" %@", _currentPlacemark.ISOcountryCode];
        }
        if (_currentPlacemark.inlandWater)
        {
            [string appendFormat:@" %@", _currentPlacemark.inlandWater];
        }
        if (_currentPlacemark.ocean)
        {
            [string appendFormat:@" %@", _currentPlacemark.ocean];
        }
    }
    
    return string;
}



- (NSString *)description
{
    return [NSString stringWithFormat:@"latitude %f, "
            "longitude %f, "
            "localizedCoordinateString %@, "
            "localizedAltitudeString %@, "
            "localizedHorizontalAccuracyString %@, "
            "localizedVerticalAccuracyString %@, "
            "localizedCourseString %@, "
            "localizedSpeedString %@",
            _currentLocation.coordinate.latitude,
            _currentLocation.coordinate.longitude,
            _currentLocation.localizedCoordinateString,
            _currentLocation.localizedAltitudeString,
            _currentLocation.localizedHorizontalAccuracyString,
            _currentLocation.localizedVerticalAccuracyString,
            _currentLocation.localizedCourseString,
            _currentLocation.localizedSpeedString];
}



@end
