//
//  MainViewController.m
//  LCTimer
//
//  Created by Eric Betts on 4/19/14.
//  Copyright (c) 2014 Eric Betts. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    [self defibrillate];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newTopic:(id)sender {
    [self setTimerFor:5*60];
}

- (IBAction)continueTopic:(id)sender {
    [self setTimerFor:2*60];
}

-(void) setTimerFor:(NSInteger)Seconds {
    NSTimeInterval ti = 1.0;

    if ([self.myTimer isValid]) {
        [NewRelic recordMetricWithName:@"Reset" category:@"Timer" value:[NSNumber numberWithInteger:Seconds]];
    } else {
        [NewRelic recordMetricWithName:@"Set" category:@"Timer" value:[NSNumber numberWithInteger:Seconds]];
    }
    
    if (self.myTimer) {
        [self.myTimer invalidate];
        self.myTimer = nil;
    }
    
    self.view.backgroundColor = [UIColor greenColor];

    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:Seconds
                                     target:self
                                   selector:@selector(timesUp)
                                   userInfo:nil
                                    repeats:NO];
    self.myTimer.tolerance = ti;
    [self.sinoatrial fire];
}

- (void) timesUp {
    AudioServicesPlaySystemSound(1006);
    [self flashScreen];
    self.view.backgroundColor = [UIColor redColor];
}

- (void) flashScreen {
    self.view.alpha = 0.0f;
	//flash animation code
	[UIView beginAnimations:@"flash screen" context:nil];
	[UIView setAnimationDuration:0.3f];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    self.view.alpha = 1.0f;
	[UIView commitAnimations];
}

- (void) heartbeat {
    if (self.myTimer && [self.myTimer isValid]) {
        [self.active startAnimating];
    } else {
        [self.active stopAnimating];
    }
}

- (void) defibrillate {
    NSTimeInterval ti = 1.0;
    if (!self.sinoatrial) {
        self.sinoatrial = [NSTimer scheduledTimerWithTimeInterval:3.0
                                                          target:self
                                                        selector:@selector(heartbeat)
                                                        userInfo:nil
                                                         repeats:YES];
        self.sinoatrial.tolerance = ti;
    }
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [(FlipsideViewController *)segue.destinationViewController setDelegate:self];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

- (IBAction)togglePopover:(id)sender
{
    if (self.flipsidePopoverController) {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    } else {
        [self performSegueWithIdentifier:@"showAlternate" sender:sender];
    }
}

@end
