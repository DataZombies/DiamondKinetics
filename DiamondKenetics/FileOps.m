//
//  FileOps.m
//  DiamondKenetics
//
//  Created by Daniel J. Pinter on 2019-02-15.
//  Copyright © 2019 DataZombies. All rights reserved.
//

#import "FileOps.h"

@interface FileOps()

@end

@implementation FileOps

-(id)init {
	if (self = [super init]) {
		[self loadSwingData];
	}

	return self;
}

-(void)loadSwingData {
	NSError *error = nil;
	NSString *datafile = [[NSBundle mainBundle] pathForResource:@"latestSwing"
														 ofType:@"csv"];
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if ([fileManager fileExistsAtPath:datafile] == YES) {
//		NSLog (@"File exists");
		NSString *contents = [NSString stringWithContentsOfFile:datafile
													  encoding:NSUTF8StringEncoding
														  error:&error];

		if (!error) {
			_swingData = [self parseCSVContents:contents];
		} else {
//			NSLog(@"File read error: %@", error);
		}
	} else {
//		NSLog (@"File not found");
	}
}

-(NSDictionary *)parseCSVContents:(NSString *)contents {
	NSArray *records = [contents componentsSeparatedByString:@"\r\n"];

	NSMutableArray *tempTimeIndex = [[NSMutableArray alloc] init];
	NSMutableArray *tempAX = [[NSMutableArray alloc] init];
	NSMutableArray *tempAY = [[NSMutableArray alloc] init];
	NSMutableArray *tempAZ = [[NSMutableArray alloc] init];
	NSMutableArray *tempWX = [[NSMutableArray alloc] init];
	NSMutableArray *tempWY = [[NSMutableArray alloc] init];
	NSMutableArray *tempWZ = [[NSMutableArray alloc] init];

	for (NSString *rec in records) {
		NSArray *temp1 = [rec componentsSeparatedByString:@","];

		[tempTimeIndex addObject:[NSNumber numberWithInt:[temp1[0] intValue]]];
		[tempAX addObject:[NSNumber numberWithFloat:[temp1[1] floatValue]]];
		[tempAY addObject:[NSNumber numberWithFloat:[temp1[2] floatValue]]];
		[tempAZ addObject:[NSNumber numberWithFloat:[temp1[3] floatValue]]];
		[tempWX addObject:[NSNumber numberWithFloat:[temp1[4] floatValue]]];
		[tempWY addObject:[NSNumber numberWithFloat:[temp1[5] floatValue]]];
		[tempWZ addObject:[NSNumber numberWithFloat:[temp1[6] floatValue]]];

	}

	return @{@"TimeIndex":tempTimeIndex,
			 @"aX":tempAX,
			 @"aY":tempAY,
			 @"aZ":tempAZ,
			 @"wX":tempWX,
			 @"wY":tempWY,
			 @"wZ":tempWZ};
}

@end
