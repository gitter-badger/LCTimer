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
    self.view.backgroundColor = [UIColor greenColor];
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
    
    if (self.myTimer) {
        [self.myTimer invalidate];
        self.myTimer = nil;
        [self timerLog:@"Invalidated timer"];
    }
    self.view.backgroundColor = [UIColor greenColor];

    [self timerLog: @"Starting timer for %li sec", Seconds];
    self.myTimer = [NSTimer scheduledTimerWithTimeInterval:Seconds
                                     target:self
                                   selector:@selector(timesUp)
                                   userInfo:nil
                                    repeats:NO];
    self.myTimer.tolerance = ti;
}

- (void) timesUp {
    self.view.backgroundColor = [UIColor redColor];
}

-(void)timerLog:(NSString*)status, ...
{
    NSDateFormatter *ISO8601 = [[NSDateFormatter alloc] init];
    [ISO8601 setDateStyle:NSDateFormatterLongStyle];
    [ISO8601 setTimeStyle:NSDateFormatterShortStyle];
    NSString *now = [ISO8601 stringFromDate:[NSDate date]];
    va_list args;
    va_start(args, status);
    NSString *message = [now stringByAppendingString:[[NSString alloc] initWithFormat:status arguments:args]];

    //NSLogv(status, args);
    va_end(args);
 
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
        [[segue destinationViewController] setDelegate:self];
        
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
