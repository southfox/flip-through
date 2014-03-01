//
//  FTLocationService.h
//  FT
//
//  Created by Javier Fuchs on 1/11/11.
//  Copyright (c) 2014 flip-through. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString* kFTLocationServiceNotification;

@interface FTLocationService : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly) CLLocation* currentLocation;

@property (nonatomic, readonly) CLPlacemark* currentPlacemark;


+ (FTLocationService *)sharedInstance;

- (void)start;

- (void)stop;

- (void)restart;

- (void)updateLocationWithCoordinate2D:(CLLocationCoordinate2D)coordinate
                         notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                          successBlock:(void (^)())successBlock;

- (void)updateLocationWithAddressString:(NSString *)addressString
                          notFoundBlock:(void (^)(NSString* errorMessage))notFoundBlock
                           successBlock:(void (^)())successBlock;

- (NSString *)localizedDescription:(BOOL)usingGPS;

- (void)obtainPlacemarkAndDistanceWithLocation:(CLLocation *)location finishBlock:(void (^)(CLPlacemark *placemark, NSNumber *distance))finishBlock;

- (NSString *)fullAddress;

@end
