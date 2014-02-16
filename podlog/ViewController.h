//
//  ViewController.h
//  podlog
//
//  Created by Johannes on 2014-01-25.
//  Copyright (c) 2014 maadi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "BEMSimpleLineGraphView.h"

@interface ViewController : UIViewController <CLLocationManagerDelegate, BEMSimpleLineGraphDelegate> {
    
    
    
    CLLocationManager *locManager;
    CLLocationSpeed speed;
    NSTimer *timer;
    
    CLLocationSpeed currentSpeed;
    float fltDistanceTravelled;
}

@property (strong, nonatomic) NSMutableArray *ArrayOfValues;
@property (strong, nonatomic) NSMutableArray *ArrayOfDates;





@end
