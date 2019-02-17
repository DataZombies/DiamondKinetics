//
//  Analytics.m
//  DiamondKenetics
//
//  Created by Daniel J. Pinter on 2019-02-15.
//  Copyright © 2019 DataZombies. All rights reserved.
//

#import "Analytics.h"

@implementation Analytics


#pragma mark - Public Methods


-(NSUInteger)searchContinuityAboveValue:(NSArray *)data
							 IndexBegin:(NSUInteger)indexBegin
							   IndexEnd:(NSUInteger)indexEnd
							  Threshold:(float)threshold
							  WinLength:(NSUInteger)winLength {

	NSLog(@"searchContinuityAboveValue");
	NSUInteger output;
	NSIndexSet *candidates =
	[data indexesOfObjectsAtIndexes:[self makeInspectionWithRange:indexBegin End:indexEnd]
							options:NSEnumerationConcurrent
						passingTest:^(id obj, NSUInteger idx, BOOL *stop){
							bool found = NO;

							if ([obj floatValue] > threshold) {
								NSLog(@"index:%lu threshold:%f dataValue:%f",
									  (unsigned long)idx, threshold, [obj floatValue]);
								found = YES;
							}

							return found;
						}
	 ];

	NSOrderedSet *final = [self findOrderedIndicesIn:candidates withWinLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];
	NSLog(@"%@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

	return output;
}

-(NSUInteger)backSearchContinuityWithinRange:(NSArray *)data
								  IndexBegin:(NSUInteger)indexBegin
									IndexEnd:(NSUInteger)indexEnd
								ThresholdLow:(float)thresholdLo
							   ThresholdHigh:(float)thresholdHi
								   WinLength:(NSUInteger)winLength {

	NSLog(@"backSearchContinuityWithinRange");
	NSUInteger output;
	NSIndexSet *candidates =
	[data indexesOfObjectsAtIndexes:[self makeInspectionWithRange:indexBegin End:indexEnd]
							options:NSEnumerationReverse
						passingTest:^(id obj, NSUInteger idx, BOOL *stop){
							bool found = NO;

							if ([obj floatValue] > thresholdLo && [obj floatValue] < thresholdHi) {
								NSLog(@"index:%lu thresholdLo:%f thresholdHi:%f dataValue:%f",
									  (unsigned long)idx, thresholdLo, thresholdHi, [obj floatValue]);
								found = YES;
							}

							return found;
						}
	 ];

	NSOrderedSet *final = [self findOrderedIndicesIn:candidates withWinLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];
	NSLog(@"%@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

	return output;
}

-(NSUInteger)searchContinuityAboveValueTwoSignals:(NSArray *)data1
											Data2:(NSArray *)data2
									   IndexBegin:(NSUInteger)indexBegin
										 IndexEnd:(NSUInteger)indexEnd
									   Threshold1:(float)threshold1
									   Threshold2:(float)threshold2
										WinLength:(NSUInteger)winLength {

	NSLog(@"searchContinuityAboveValueTwoSignals");
	NSUInteger output;

	//Signal 1
	NSIndexSet *candidates1 =
	[data1 indexesOfObjectsAtIndexes:[self makeInspectionWithRange:indexBegin End:indexEnd]
							 options:NSEnumerationConcurrent
						 passingTest:^(id obj, NSUInteger idx, BOOL *stop){
							 bool found = NO;

							 if ([obj floatValue] > threshold1) {
								 NSLog(@"index:%lu threshold1:%f dataValue:%f",
									   (unsigned long)idx, threshold1, [obj floatValue]);
								 found = YES;
							 }

							 return found;
						 }
	 ];
	NSSet *final1 = [self findIndicesIn:candidates1 withWinLength:winLength];

	// Signal 2
	NSIndexSet *candidates2 =
	[data2 indexesOfObjectsAtIndexes:[self makeInspectionWithRange:indexBegin End:indexEnd]
							 options:NSEnumerationConcurrent
						 passingTest:^(id obj, NSUInteger idx, BOOL *stop){
							 bool found = NO;

							 if ([obj floatValue] > threshold2) {
								 NSLog(@"index:%lu threshold2:%f dataValue:%f",
									   (unsigned long)idx, threshold2, [obj floatValue]);
								 found = YES;
							 }

							 return found;
						 }
	 ];
	NSSet *final2 = [self findIndicesIn:candidates2 withWinLength:winLength];

	NSMutableSet *final1MutableCopy = [final1 mutableCopy];
	[final1MutableCopy intersectSet:final2];
	NSOrderedSet *finalOrderedSet = [NSOrderedSet orderedSetWithSet:[final1MutableCopy copy]];
	output = [[finalOrderedSet firstObject] unsignedIntegerValue];
	NSLog(@"%@", !output ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]);

	return output;
}

-(NSOrderedSet *)searchMultiContinuityWithinRange:(NSArray *)data
									 IndexBegin:(NSUInteger)indexBegin
									   IndexEnd:(NSUInteger)indexEnd
								   ThresholdLow:(float)thresholdLo
								  ThresholdHigh:(float)thresholdHi
									  WinLength:(NSUInteger)winLength {

	NSLog(@"searchMultiContinuityWithinRange");
	NSIndexSet *candidates =
	[data indexesOfObjectsAtIndexes:[self makeInspectionWithRange:indexBegin End:indexEnd]
							options:NSEnumerationReverse
						passingTest:^(id obj, NSUInteger idx, BOOL *stop){
							bool found = NO;

							if ([obj floatValue] > thresholdLo && [obj floatValue] < thresholdHi) {
								NSLog(@"index:%lu thresholdLo:%f thresholdHi:%f dataValue:%f",
									  (unsigned long)idx, thresholdLo, thresholdHi, [obj floatValue]);
								found = YES;
							}

							return found;
						}
	 ];

	NSOrderedSet *output = [self findOrderedIndicesIn:candidates withWinLength:winLength];
	NSLog(@"%@", (output.count == 0 ? @"Not Found" : output));

	return output;
}


#pragma mark - Private Methods


// Look for indices with a length greater than winLength and return an ordered set.
-(NSOrderedSet *)findOrderedIndicesIn:(NSIndexSet *)input withWinLength:(NSUInteger)length {
	NSMutableOrderedSet *output = [NSMutableOrderedSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= length) {
			[output addObject:[NSNumber numberWithUnsignedInteger:range.location]];
		}
	}];

	return output;
}

// Look for indices with a length greater than winLength and return an disordered set.
-(NSSet *)findIndicesIn:(NSIndexSet *)input withWinLength:(NSUInteger)length {
	NSMutableSet *output = [NSMutableSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= length) {
			[output addObject:[NSNumber numberWithUnsignedInteger:range.location]];
		}
	}];

	return output;
}

//Create a range to be queried using begin and end.
-(NSIndexSet *)makeInspectionWithRange:(NSUInteger)begin End:(NSUInteger)end {
	NSRange range;
	NSIndexSet *output;

	if (begin <= end) {
		range = NSMakeRange(begin, end - begin + 1);
	} else {
		range = NSMakeRange(end, begin - end + 1);
	}
	output = [NSIndexSet indexSetWithIndexesInRange:range];

	NSLog(@"%@", output);

	return output;
}

@end
