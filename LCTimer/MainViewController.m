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
    [self updateTimeLabel];
    [self defibrillate];
    self.remaining = 0;
    self.total = 0;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)newTopic:(id)sender {
    [self setTimerFor:5*MINUTE];
}

- (IBAction)continueTopic:(id)sender {
    [self setTimerFor:2*MINUTE];
}

-(void) setTimerFor:(NSInteger)Seconds {
    self.total = Seconds;

    if (self.remaining > 0) {
        [NewRelic recordMetricWithName:@"Reset" category:@"Timer" value:[NSNumber numberWithInteger:Seconds]];
    } else {
        [NewRelic recordMetricWithName:@"Set" category:@"Timer" value:[NSNumber numberWithInteger:Seconds]];
    }
    
    self.remaining = Seconds;
    self.view.backgroundColor = [UIColor greenColor];
    [self.sinoatrial fire];
    [self.active startAnimating];
}

- (void) timesUp {
    AudioServicesPlaySystemSound(1006);
    [self flashScreen];
    self.view.backgroundColor = [UIColor redColor];
    [self.active stopAnimating];
    self.total = 0;
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

- (void) heartbeat:(NSTimer *)timer {
    //A timer has been set
    if (self.total > 0) {
        self.progress.progress = 1 - (self.remaining / (float)self.total);
        if (self.remaining > 0) {//hasn't expired
            self.remaining = self.remaining - 1;
        } else {
            [self timesUp];
            [timer invalidate];
        }
        NSLog(@"[Heartbeat] %li of %li (%f)", (long)self.remaining, (long)self.total, self.progress.progress);
    } else {
        self.progress.progress = 0.0;
    }
    [self updateTimeLabel];
}

- (void) defibrillate { //Start heartbeat
    NSTimeInterval ti = 0.1;
    if (!self.sinoatrial) {
        self.sinoatrial = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                         selector:@selector(heartbeat:)
                                                        userInfo:nil
                                                         repeats:YES];
        self.sinoatrial.tolerance = ti;
    }
}

- (void) updateTimeLabel {
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *dateComponents = [gregorian components:(NSHourCalendarUnit  | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:now];
    NSInteger hour = [dateComponents hour];
    NSInteger minute = [dateComponents minute];
    //NSInteger second = [dateComponents second];
    self.currentTime.text = [NSString stringWithFormat:@"%02li:%02li", hour, minute];
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
