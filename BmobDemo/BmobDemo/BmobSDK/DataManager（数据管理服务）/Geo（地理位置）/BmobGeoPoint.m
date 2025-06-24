//
//  BmobGeoPoint.m
//  BmobSDK
//
//  Created by Bmob on 13-8-6.
//  Copyright (c) 2013年 Bmob. All rights reserved.
//

#import "BmobGeoPoint.h"


@implementation BmobGeoPoint

@synthesize latitude=_latitude,longitude=_longitude;

-(id)initWithLongitude:(double)mylongitude   WithLatitude:(double)mylatitude{
    
    self = [super init];
    
    if (self ) {
        if (mylatitude >= 90 || mylatitude <=-90) {
            _latitude = 0;
            
        }
        else if(mylongitude >= 180 || mylongitude <=-180){
            _longitude = 0;
        } else{
            _latitude = mylatitude;
            _longitude = mylongitude;
        }
    }

    return self;
}



-(void)setLongitude:(double)mylongitude Latitude:(double)mylatitude{
    
    if (mylatitude >= 90 || mylatitude <=-90) {

        return;
        
    }
    else if(mylongitude >= 180 || mylongitude <=-180){
        return;
    }
    
    self.latitude = mylatitude;
    self.longitude = mylongitude;
}

-(id)init{
    
    self = [super init];
    if (self) {
        
        _latitude = 0.0f;
        _longitude = 0.0f;
       
    }
    
    return self;
}







/** @name Calculating Distance */


- (double)distanceInRadiansTo:(BmobGeoPoint*)point{
    return 0;
}


- (double)distanceInMilesTo:(BmobGeoPoint*)point{
    return 0;
}


- (double)distanceInKilometersTo:(BmobGeoPoint*)point{
    return 0;
}



-(void)dealloc{
    
//    [super dealloc];
    
    
}

@end
