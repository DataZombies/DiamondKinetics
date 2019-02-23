//
//  ViewController.m
//  DiamondKinetics
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
											  indexBegin:0
												indexEnd:_max
											   threshold:0.818359f
											   winLength:5];
	_lblOutput.text = (x == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)x]);
}

-(IBAction)q2TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSUInteger x = [analytics backSearchContinuityWithinRange:_fileOps.swingData[@"aX"]
												   indexBegin:_max
													 indexEnd:_max - 50
												  thresholdLo:0.12207
												  thresholdHi:0.169922
													winLength:3];
	_lblOutput.text = (x == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)x]);
}

-(IBAction)q3TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSUInteger x = [analytics searchContinuityAboveValueTwoSignals:_fileOps.swingData[@"aY"]
															 data2:_fileOps.swingData[@"wY"]
														indexBegin:0
														  indexEnd:_max
														threshold1:5
														threshold2:10
														 winLength:5];
	_lblOutput.text = (!x ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)x]);
}

-(IBAction)q4TouchUp:(id)sender {
	Analytics *analytics = [Analytics new];

	NSOrderedSet *x = [analytics searchMultiContinuityWithinRange:_fileOps.swingData[@"aY"]
													   indexBegin:0
														 indexEnd:500
													  thresholdLo:0.3
													  thresholdHi:0.5
														winLength:5];

	_lblOutput.text = [NSString stringWithFormat:@"%@", (x.count == 0 ? @"Not Found" : x)];
}

@end

