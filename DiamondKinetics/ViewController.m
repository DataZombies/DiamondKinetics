//
//  ViewController.m
//  DiamondKenetics
//
//  Created by Daniel J. Pinter on 2019-02-15.
//  Copyright © 2019 DataZombies. All rights reserved.
//

#import "ViewController.h"
#import "FileOps.h"
#import "Analytics.h"

@interface ViewController ()

@property NSUInteger max;
@property (strong, nonatomic) FileOps *fileOps;
@property (weak, nonatomic) IBOutlet UILabel *lblDataLoaded;
@property (weak, nonatomic) IBOutlet UILabel *lblOutput;

@end

@implementation ViewController

-(void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

	_fileOps = [FileOps sharedFileOpsManager];

	if (_fileOps.swingData != nil) {
		_lblDataLoaded.text = @"Data is loaded.";
		_max = [_fileOps.swingData[@"TimeIndex"] count] - 1;
	} else {
		_lblDataLoaded.text = @"There was a error loading the data.";
	}

	_lblOutput.text = @"";
}

-(IBAction)q1TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSUInteger x = [analytics searchContinuityAboveValue:_fileOps.swingData[@"aX"]
											  IndexBegin:0
												IndexEnd:_max
											   Threshold:0.818359f
											   WinLength:5];
	_lblOutput.text = (x == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)x]);
}

-(IBAction)q2TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSUInteger x = [analytics backSearchContinuityWithinRange:_fileOps.swingData[@"aX"]
												   IndexBegin:_max
													 IndexEnd:_max - 34
												 ThresholdLow:0.12207
												ThresholdHigh:0.169922
													WinLength:3];
	_lblOutput.text = (x == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)x]);
}

-(IBAction)q3TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSUInteger x = [analytics searchContinuityAboveValueTwoSignals:_fileOps.swingData[@"aY"]
															 Data2:_fileOps.swingData[@"wY"]
														IndexBegin:800
														  IndexEnd:900
														Threshold1:7
														Threshold2:33
														 WinLength:5];
	_lblOutput.text = (!x ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)x]);
}

-(IBAction)q4TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSOrderedSet *x = [analytics searchMultiContinuityWithinRange:_fileOps.swingData[@"aY"]
													 IndexBegin:0
													   IndexEnd:500
												   ThresholdLow:0.3
												  ThresholdHigh:0.5
													  WinLength:5];

	_lblOutput.text = [NSString stringWithFormat:@"%@", (x.count == 0 ? @"Not Found" : x)];
}

@end
