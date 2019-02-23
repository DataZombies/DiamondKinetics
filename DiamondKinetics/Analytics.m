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
							 indexBegin:(NSUInteger)indexBegin
							   indexEnd:(NSUInteger)indexEnd
							  threshold:(float)threshold
							  winLength:(NSUInteger)winLength {
	NSLog(@"searchContinuityAboveValue");

	NSUInteger output;
	NSIndexSet *candidates = [self indexSetSearchWithData:data
												 range:[self makeInspectionRangeWithBegin:indexBegin
																					  end:indexEnd]
											   option:NSEnumerationConcurrent
										  comparisonBlock:^BOOL(id o, NSUInteger i) {
											  return [self testGreaterThanWithObject:o
																		   threshold:threshold
																			   index:i];
										  }];
	NSOrderedSet *final = [self findOrderedIndicesIn:candidates winLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];

	NSLog(@"candidates: %@", candidates);
	NSLog(@"final: %@", final);
	NSLog(@"output: %@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

	return output;
}

-(NSUInteger)backSearchContinuityWithinRange:(NSArray *)data
								  indexBegin:(NSUInteger)indexBegin
									indexEnd:(NSUInteger)indexEnd
								 thresholdLo:(float)thresholdLo
								 thresholdHi:(float)thresholdHi
								   winLength:(NSUInteger)winLength {
	NSLog(@"backSearchContinuityWithinRange");

	NSUInteger output;
	NSIndexSet *candidates = [self indexSetSearchWithData:data
												 range:[self makeInspectionRangeWithBegin:indexBegin
																					  end:indexEnd]
											   option:NSEnumerationReverse
										  comparisonBlock:^BOOL(id o, NSUInteger i) {
											  return [self testOpenIntervalWithObject:o
																		 lowThreshold:thresholdLo
																		highThreshold:thresholdHi
																				index:i];
										  }];
	NSOrderedSet *final = [self findOrderedIndicesIn:candidates winLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];

	NSLog(@"candidates: %@", candidates);
	NSLog(@"final: %@", final);
	NSLog(@"output: %@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

	return output;
}

-(NSUInteger)searchContinuityAboveValueTwoSignals:(NSArray *)data1
											data2:(NSArray *)data2
									   indexBegin:(NSUInteger)indexBegin
										 indexEnd:(NSUInteger)indexEnd
									   threshold1:(float)threshold1
									   threshold2:(float)threshold2
										winLength:(NSUInteger)winLength {
	NSLog(@"searchContinuityAboveValueTwoSignals");

	NSUInteger output;
	//Signal 1
	NSIndexSet *candidates1 = [self indexSetSearchWithData:data1
												  range:[self makeInspectionRangeWithBegin:indexBegin
																					   end:indexEnd]
												option:NSEnumerationConcurrent
										   comparisonBlock:^BOOL(id o, NSUInteger i) {
											   return [self testGreaterThanWithObject:o
																			threshold:threshold1
																				index:i];
										   }];
	// Signal 2
	NSIndexSet *candidates2 = [self indexSetSearchWithData:data2
												  range:[self makeInspectionRangeWithBegin:indexBegin
																					   end:indexEnd]
												option:NSEnumerationConcurrent
										   comparisonBlock:^BOOL(id o, NSUInteger i) {
											   return [self testGreaterThanWithObject:o
																			threshold:threshold2
																				index:i];
										   }];
	NSOrderedSet *final = [self findIntersectionOfIndexSet1:candidates1 indexSet2:candidates2 forWinLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];

	NSLog(@"\ncandidates1: %@\ncandidates2: %@", candidates1, candidates2);
	NSLog(@"final: %@", final);
	NSLog(@"output: %@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

	return output;
}

-(NSIndexSet *)searchMultiContinuityWithinRange:(NSArray *)data
									 indexBegin:(NSUInteger)indexBegin
									   indexEnd:(NSUInteger)indexEnd
									thresholdLo:(float)thresholdLo
									thresholdHi:(float)thresholdHi
									  winLength:(NSUInteger)winLength {
	NSLog(@"searchMultiContinuityWithinRange");

	NSIndexSet *output;
	NSIndexSet *candidates = [self indexSetSearchWithData:data
												 range:[self makeInspectionRangeWithBegin:indexBegin
																					  end:indexEnd]
											   option:NSEnumerationConcurrent
										  comparisonBlock:^BOOL(id o, NSUInteger i) {
											  return [self testOpenIntervalWithObject:o
																		 lowThreshold:thresholdLo
																		highThreshold:thresholdHi
																				index:i];
										  }];
	output = [self findRangesIn:candidates winLength:winLength];

	NSLog(@"output: %@", (output.count == 0 ? @"Not Found" : output));

	return output;
}


#pragma mark - Private Comparison Methods


-(BOOL)testGreaterThanWithObject:(id)o threshold:(float)t index:(NSUInteger)i {
//	if ([o floatValue] > t) {
//		NSLog(@"Search: index:%lu threshold:%f dataValue:%f",
//			  (unsigned long)i, threshold, [o floatValue]);
//	}

	return ([o floatValue] > t);
}

-(BOOL)testOpenIntervalWithObject:(id)o lowThreshold:(float)lT highThreshold:(float)hT index:(NSUInteger)i {
//	if ([o floatValue] > lT && [o floatValue] < hT) {
//		NSLog(@"Search: index:%lu thresholdLo:%f thresholdHi:%f dataValue:%f",
//			  (unsigned long)i, lT, hT, [o floatValue]);
//	}

	return ([o floatValue] > lT && [o floatValue] < hT);
}


#pragma mark - Private Methods


// Look for indices with a length greater than winLength and return a disordered set.
-(NSSet *)findIndicesIn:(NSIndexSet *)input winLength:(NSUInteger)winLength {
	NSMutableSet *output = [NSMutableSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= winLength) {
			[output addObject:[NSNumber numberWithUnsignedInteger:range.location]];
		}
	}];

	return output;
}

// Find the intersection of two sets where the overlap is equal to or greater than winLength.
// Return the index where the overlap begins.
-(NSOrderedSet *)findIntersectionOfIndexSet1:(NSIndexSet *)set1 indexSet2:(NSIndexSet *)set2 forWinLength:(NSUInteger)winLength {
	NSMutableOrderedSet *output = [NSMutableOrderedSet new];

	[set1 enumerateRangesUsingBlock:^(NSRange range1, BOOL *stop1) {
		[set2 enumerateRangesUsingBlock:^(NSRange range2, BOOL *stop2) {
			NSRange intersection = NSIntersectionRange(range1, range2);
			NSLog(@"\nrange1: %@\nrange2: %@\nIntersection: %@",
				  NSStringFromRange(range1), NSStringFromRange(range2), NSStringFromRange(intersection));

			if (intersection.length >= winLength) {
				if (range1.location >= range2.location) {
					[output addObject:[NSNumber numberWithUnsignedInteger:range1.location]];
				} else {
					[output addObject:[NSNumber numberWithUnsignedInteger:range2.location]];
				}
			}
		}];
	}];

	return output;
}

// Look for indices with a length greater than winLength and return an ordered set.
-(NSOrderedSet *)findOrderedIndicesIn:(NSIndexSet *)input winLength:(NSUInteger)winLength {
	NSMutableOrderedSet *output = [NSMutableOrderedSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= winLength) {
			[output addObject:[NSNumber numberWithUnsignedInteger:range.location]];
		}
	}];

	return output;
}

// Look for indices in a range with a length greater than winLength and return an indexed set.
-(NSIndexSet *)findRangesIn:(NSIndexSet *)input winLength:(NSUInteger)winLength {
	NSMutableIndexSet *output = [NSMutableIndexSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= winLength) {
			NSIndexSet *temp = [NSIndexSet indexSetWithIndexesInRange:range];
			[output addIndexes:temp];
		}
	}];

	return [output copy];
}

// Perform the signal search and return indexes where the data satisfies the
// comparison.
-(NSIndexSet *)indexSetSearchWithData:(NSArray *)data range:(NSIndexSet *)range option:(NSEnumerationOptions)option comparisonBlock:(BOOL(^)(id o, NSUInteger idx))comparisonBlock {

	return [data indexesOfObjectsAtIndexes:range
								   options:option
							   passingTest:^(id obj, NSUInteger idx, BOOL *stop){
								   return comparisonBlock(obj, idx);
							   }];
}

// Create a range to be queried using begin and end.
-(NSIndexSet *)makeInspectionRangeWithBegin:(NSUInteger)begin end:(NSUInteger)end {
	NSRange range;
	NSIndexSet *output;

	if (begin <= end) {
		range = NSMakeRange(begin, end - begin + 1);
	} else {
		range = NSMakeRange(end, begin - end + 1);
	}
	output = [NSIndexSet indexSetWithIndexesInRange:range];

	NSLog(@"Range: %@", output);

	return output;
}

@end

