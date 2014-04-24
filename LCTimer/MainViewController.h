//
//  MainViewController.h
//  LCTimer
//
//  Created by Eric Betts on 4/19/14.
//  Copyright (c) 2014 Eric Betts. All rights reserved.
//

#import "FlipsideViewController.h"
#import <AudioToolbox/AudioToolbox.h>


@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *active;

@property NSTimer *myTimer;
@property NSTimer *sinoatrial;

@end
