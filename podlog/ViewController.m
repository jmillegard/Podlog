//
//  ViewController.m
//  podlog
//
//  Created by Johannes on 2014-01-25.
//  Copyright (c) 2014 maadi. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

#define PORTRAIT_LABEL_SIZE 180
#define LANDSCAPE_LABEL_SIZE 280
#define LANDSCAPE_LABEL_SIZE_AV 180
#define FONT_NAME @"Helvetica-Bold"

#define IPAD UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad

@interface ViewController ()

@end

@implementation ViewController

UILabel * bigSpeed;
UILabel * topSpeed;
UILabel * averageSpeed;

int speedLabelSizeLandscape;
int speedLabelSizePortrait;

int totalNumber;
int interval;
int colorPicked;

BOOL viewHasChanged;
BOOL maxSpeedState;
BOOL maxSpeedState;
BOOL isMirrored;

UIColor * darkBackground;
UIColor * lightBackground;

NSTimer * speedTimer;
NSTimer * graphTimer;

NSInteger _speed;
NSInteger _maxSpeed;



BEMSimpleLineGraphView * speedGraph;

UIView * speedView;

UIView * graphView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    speedLabelSizeLandscape = LANDSCAPE_LABEL_SIZE;
    speedLabelSizePortrait = PORTRAIT_LABEL_SIZE;
    
    if (IPAD) {
        //speedLabelSizeLandscape = 460;
        //speedLabelSizePortrait = 380;
    } else {
        // iPhone / iPod Touch
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myRightAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionRight)];

    [self.view addGestureRecognizer:recognizer];
    
    UISwipeGestureRecognizer * recognizerLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(myLeftAction:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionLeft)];
    
    [self.view addGestureRecognizer:recognizer];
    
    [self.view addGestureRecognizer:recognizerLeft];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    
    tapGesture.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer:tapGesture];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin];

    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    locManager = [[CLLocationManager alloc] init];
    
    locManager.delegate = self;
    
    locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    
    [locManager startUpdatingLocation];
    
    [self initSpeedView];
    
    //[self initGraphView];
    
    graphView.hidden = YES;
    
    viewHasChanged = NO;
    
    maxSpeedState = NO;
    
    isMirrored = NO;
    
    colorPicked = 1;
    
    if (UIDeviceOrientationIsLandscape([UIDevice currentDevice].orientation))
    {
        [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
        
        [speedGraph setFrame:CGRectMake(0, 0, 640, 400)];
        
        [averageSpeed setFrame:CGRectMake(0, 100, speedView.frame.size.width , speedView.frame.size.height)];
    }
    
    if (UIDeviceOrientationIsPortrait([UIDevice currentDevice].orientation))
    {
        [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizePortrait]];
        
        [speedGraph setFrame:CGRectMake(0, 0, 640, 70)];
        
        [averageSpeed setFrame:CGRectMake(0, 140, speedView.frame.size.width , speedView.frame.size.height)];
    }
    
    //graphTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateGraph) userInfo:nil repeats:YES];
    
    graphTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(checkSpeed) userInfo:nil repeats:YES];
    
}

- (void) updateSpeed {
    
    
    [self.ArrayOfValues addObject:[NSNumber numberWithInteger:_speed]];
    
    [self.ArrayOfDates addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: interval]]];
    
    totalNumber = totalNumber + [[self.ArrayOfValues objectAtIndex:interval] intValue];
    
    interval++;
    
    int value = [[self.ArrayOfValues valueForKeyPath:@"@avg.floatValue"] intValue];
    
    if(value < 0) {
        value = 0;
    }
    
    averageSpeed.text = [NSString stringWithFormat:@"%d", value];
    
    [self updateGraph];
    
}

- (void) checkSpeed {
    if(_speed > _maxSpeed) {
        bigSpeed.backgroundColor = [UIColor redColor];
    } else {
        bigSpeed.backgroundColor = [UIColor blackColor];
    }
    
}

- (void) updateGraph {
    [speedGraph reloadGraph];
}

- (void)handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {

        if(maxSpeedState) {
            topSpeed.hidden = NO;
            speedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
            maxSpeedState = NO;
        }
        else {
            topSpeed.hidden = YES;
            maxSpeedState = YES;
        }
        
        
    }
}


- (void) locationManager:(CLLocationManager *)manager
     didUpdateToLocation:(CLLocation *)newLocation
            fromLocation:(CLLocation *)oldLocation {
    
    _speed = newLocation.speed * 3600 / 1000;
    
    _speed += 93;
    
    NSString * km;
    
    if(_speed > 0.0f) {
        km = [NSString stringWithFormat:@"%ld", (long)_speed];
    } else {
        [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizePortrait]];
        km = [NSString stringWithFormat:@"S"];
    }

    bigSpeed.text = km;
    
}

- (void) initGraphView {
    
    interval = 1;
    
    _speed = 1.0f;
    
    self.ArrayOfValues = [[NSMutableArray alloc] init];
    
    self.ArrayOfDates = [[NSMutableArray alloc] init];
    
    totalNumber = 0;
    
    for (int i=0; i < 2; i++) {
        
        [self.ArrayOfValues addObject:[NSNumber numberWithInteger:(1 + i)]];
    
        [self.ArrayOfDates addObject:[NSString stringWithFormat:@"%@",[NSNumber numberWithInt: i]]];
        
        totalNumber = totalNumber + [[self.ArrayOfValues objectAtIndex:i] intValue];
    
    }
    
    graphView = [[UIView alloc] initWithFrame:self.view.frame];
    
    graphView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    

    speedGraph = [[BEMSimpleLineGraphView alloc] init];
    
    [speedGraph setFrame:self.view.frame];
    
    speedGraph.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    speedGraph.enableTouchReport = NO;
    
    speedGraph.colorTop = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    speedGraph.colorBottom = [UIColor colorWithRed:0 green:0 blue:0 alpha:1.0];
    
    speedGraph.colorLine = [UIColor whiteColor];
    
    speedGraph.animationGraphEntranceSpeed = 0;
    
    speedGraph.colorXaxisLabel = [UIColor blackColor];
    
    speedGraph.widthLine = 3.0;
    
    speedGraph.enableTouchReport = NO;
    
    speedGraph.delegate = self;
    
    // Init average label
    
    
    averageSpeed = [[UILabel alloc] initWithFrame:CGRectMake(0, 100, speedView.frame.size.width , speedView.frame.size.height)];
    
    averageSpeed.backgroundColor = [UIColor clearColor];
    
    averageSpeed.textColor = [UIColor whiteColor];
    
    averageSpeed.textAlignment = NSTextAlignmentCenter;
    
    [averageSpeed setFont: [UIFont fontWithName:FONT_NAME size:LANDSCAPE_LABEL_SIZE]];
    
    averageSpeed.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    averageSpeed.text = @"0";
    
    [graphView addSubview:averageSpeed];
    
    [self.view addSubview:graphView];
    
    [graphView addSubview:speedGraph];
    
    speedTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateSpeed) userInfo:nil repeats:YES];
    
    
}

- (void) initSpeedView {
    
    speedView = [[UIView alloc] initWithFrame:self.view.frame];
    
    speedView.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;

    bigSpeed = [[UILabel alloc] initWithFrame:speedView.frame];
    
    bigSpeed.backgroundColor = [UIColor blackColor];
    
    bigSpeed.textColor = [UIColor whiteColor];
    
    bigSpeed.textAlignment = NSTextAlignmentCenter;
    
    [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
    
    bigSpeed.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    bigSpeed.text = @"0";
    
    topSpeed = [[UILabel alloc] initWithFrame:speedView.frame];
    
    topSpeed.backgroundColor = [UIColor whiteColor];
    
    topSpeed.textColor = [UIColor blackColor];
    
    topSpeed.textAlignment = NSTextAlignmentCenter;
    
    [topSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
    
    topSpeed.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
    
    topSpeed.text = @"120";
    
    topSpeed.hidden = YES;
    
    [speedView addSubview:bigSpeed];
    
    [speedView addSubview:topSpeed];
    
    [self.view addSubview:speedView];
    
}

- (void) orientationChanged:(NSNotification *)note
{
    UIDevice * device = note.object;
    
    switch(device.orientation)
    {
        case UIDeviceOrientationPortrait:
            
            [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizePortrait]];
            
            [topSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizePortrait]];
            
            [speedGraph setFrame:CGRectMake(0, 0, 640, 70)];
            
            [averageSpeed setFrame:CGRectMake(0, 140, speedView.frame.size.width , speedView.frame.size.height)];
            
            break;
            
        case UIDeviceOrientationLandscapeLeft:
            
            [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
            
            [topSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
        
            [speedGraph setFrame:CGRectMake(0, 0, 640, 400)];
            
            [averageSpeed setFrame:CGRectMake(0, 100, speedView.frame.size.width , speedView.frame.size.height)];
            
            break;
            
        case UIDeviceOrientationLandscapeRight:
            
            [topSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
            
            [bigSpeed setFont: [UIFont fontWithName:FONT_NAME size:speedLabelSizeLandscape]];
            
            [speedGraph setFrame:CGRectMake(0, 0, 640, 400)];
            
            [averageSpeed setFrame:CGRectMake(0, 100, speedView.frame.size.width , speedView.frame.size.height)];

            
            break;
            
        case UIDeviceOrientationPortraitUpsideDown:

            break;
            
        default:
    
            break;
    };
}

- (void) myRightAction: (UISwipeGestureRecognizer *) recognizer {
    if(maxSpeedState) {
        speedView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        isMirrored = NO;
    }
}

- (void) myLeftAction: (UISwipeGestureRecognizer *) recognizer {
    if(maxSpeedState) {
        speedView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
        isMirrored = YES;
    }
}


#pragma mark - SimpleLineGraph Data Source

- (int)numberOfPointsInGraph {
    
    return (int)[self.ArrayOfValues count];
}

- (float)valueForIndex:(NSInteger)index {
    
    return [[self.ArrayOfValues objectAtIndex:index] floatValue];
}

#pragma mark - SimpleLineGraph Delegate

- (int)numberOfGapsBetweenLabels {
    return 1;
}

- (NSString *)labelOnXAxisForIndex:(NSInteger)index {
    return [self.ArrayOfDates objectAtIndex:index];
}

- (void)didTouchGraphWithClosestIndex:(int)index {
    averageSpeed.text = [NSString stringWithFormat:@"%@", [self.ArrayOfValues objectAtIndex:index]];
}

- (void)didReleaseGraphWithClosestIndex:(float)index {

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //[self performSelector:@selector(longTap) withObject:nil afterDelay:1.0];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touch ended");
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longTap) object:nil];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if(!maxSpeedState) {
        
        UITouch *touch=[[event allTouches]anyObject];
        
        CGPoint point = [touch locationInView:touch.view];
    
        NSString * maxV = [NSString stringWithFormat:@"%.0f", point.y];
        
        _maxSpeed = [maxV integerValue];
        
        if ( ( _maxSpeed % 5 ) == 0 ) {
            topSpeed.text = [NSString stringWithFormat:@"%d", _maxSpeed];
        }
    
        
    }
    
    //[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longTap) object:nil];
}

-(void) longTap 
{
    
    
    NSLog(@"handle long tap..");
}

@end
