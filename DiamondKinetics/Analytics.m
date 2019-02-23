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
	NSIndexSet *candidates = [self indexSetSearchWithData:data
													Range:[self makeInspectionWithRange:indexBegin
																					End:indexEnd]
											   Thresholds:@[[NSNumber numberWithFloat:threshold]]
												   Option:NSEnumerationConcurrent
											   Comparison:@"GreaterThan"
							  ];

	NSOrderedSet *final = [self findOrderedIndicesIn:candidates withWinLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];

	NSLog(@"candidates: %@", candidates);
	NSLog(@"final: %@", final);
	NSLog(@"output: %@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

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
	NSIndexSet *candidates = [self indexSetSearchWithData:data
													Range:[self makeInspectionWithRange:indexBegin
																					End:indexEnd]
											   Thresholds:@[[NSNumber numberWithFloat:thresholdLo],
															[NSNumber numberWithFloat:thresholdHi]]
												   Option:NSEnumerationReverse
											   Comparison:@"OpenInterval"];

	NSOrderedSet *final = [self findOrderedIndicesIn:candidates withWinLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];

	NSLog(@"candidates: %@", candidates);
	NSLog(@"final: %@", final);
	NSLog(@"output: %@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

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
	NSIndexSet *candidates1 = [self indexSetSearchWithData:data1
													 Range:[self makeInspectionWithRange:indexBegin
																					 End:indexEnd]
												Thresholds:@[[NSNumber numberWithFloat:threshold1]]
													Option:NSEnumerationConcurrent
												Comparison:@"GreaterThan"];
// Signal 2
	NSIndexSet *candidates2 = [self indexSetSearchWithData:data2
													 Range:[self makeInspectionWithRange:indexBegin
																					 End:indexEnd]
												Thresholds:@[[NSNumber numberWithFloat:threshold2]]
													Option:NSEnumerationConcurrent
												Comparison:@"GreaterThan"];

	NSOrderedSet *final = [self findIntersectionOfIndexSet1:candidates1 IndexSet2:candidates2 forWinLength:winLength];
	output = [[final firstObject] unsignedIntegerValue];

	NSLog(@"\ncandidates1: %@\ncandidates2: %@", candidates1, candidates2);
	NSLog(@"final: %@", final);
	NSLog(@"output: %@", (output == NSNotFound ? @"Not Found" : [NSString stringWithFormat:@"%lu", (unsigned long)output]));

	return output;
}

-(NSIndexSet *)searchMultiContinuityWithinRange:(NSArray *)data
									 IndexBegin:(NSUInteger)indexBegin
									   IndexEnd:(NSUInteger)indexEnd
								   ThresholdLow:(float)thresholdLo
								  ThresholdHigh:(float)thresholdHi
									  WinLength:(NSUInteger)winLength {
	NSLog(@"searchMultiContinuityWithinRange");

	NSIndexSet *output;
	NSIndexSet *candidates = [self indexSetSearchWithData:data
													Range:[self makeInspectionWithRange:indexBegin
																					End:indexEnd]
											   Thresholds:@[[NSNumber numberWithFloat:thresholdLo],
															[NSNumber numberWithFloat:thresholdHi]]
												   Option:NSEnumerationConcurrent
											   Comparison:@"OpenInterval"];

	output = [self findRangesIn:candidates withWinLength:winLength];

	NSLog(@"output: %@", (output.count == 0 ? @"Not Found" : output));

	return output;
}


#pragma mark - Private Comparison Methods


-(BOOL)testGreaterThanWithThreshold:(float)threshold withObject:(id)obj atIndex:(NSUInteger)idx {
	return ([obj floatValue] > threshold);
//	BOOL found = NO;
//
//	if ([obj floatValue] > threshold) {
//		NSLog(@"Search: index:%lu threshold:%f dataValue:%f",
//			  (unsigned long)idx, threshold, [obj floatValue]);
//		found = YES;
//	}
//
//	return found;
}

-(BOOL)testOpenIntervalWithLowThreshold:(float)lowThreshold HighThreshold:(float)highThreshold withObject:(id)obj atIndex:(NSUInteger)idx {
	return ([obj floatValue] > lowThreshold && [obj floatValue] < highThreshold);
//	BOOL found = NO;
//
//	if ([obj floatValue] > lowThreshold && [obj floatValue] < highThreshold) {
//		NSLog(@"Search: index:%lu thresholdLo:%f thresholdHi:%f dataValue:%f",
//			  (unsigned long)idx, lowThreshold, highThreshold, [obj floatValue]);
//		found = YES;
//	}
//
//	return found;
}


#pragma mark - Private Methods


-(NSIndexSet *)indexSetSearchWithData:(NSArray *)data
								Range:(NSIndexSet *)range
						   Thresholds:(NSArray *)thresholds
							   Option:(NSEnumerationOptions)option
						   Comparison:(NSString *)comparison {
//                         Comparison:(void (^)(id, NSUInteger, BOOL *))comparison {
	return [data indexesOfObjectsAtIndexes:range
								   options:option
							   passingTest:^(id obj, NSUInteger idx, BOOL *stop){
								   BOOL found = NO;

								   if ([comparison isEqualToString:@"GreaterThan"] && thresholds.count == 1) {
									   found = [self testGreaterThanWithThreshold:[thresholds[0] floatValue]
																	   withObject:obj
																		  atIndex:idx];
								   } else if ([comparison isEqualToString:@"OpenInterval"] && thresholds.count == 2) {
									   found = [self testOpenIntervalWithLowThreshold:[thresholds[0] floatValue]
																		HighThreshold:[thresholds[1] floatValue]
																		   withObject:obj
																			  atIndex:idx];
								   }

								   return found;
						   }
			];
}

// Look for indices with a length greater than winLength and return a disordered set.
-(NSSet *)findIndicesIn:(NSIndexSet *)input withWinLength:(NSUInteger)winLength {
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
-(NSOrderedSet *)findIntersectionOfIndexSet1:(NSIndexSet *)set1 IndexSet2:(NSIndexSet *)set2 forWinLength:(NSUInteger)winLength {
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
-(NSOrderedSet *)findOrderedIndicesIn:(NSIndexSet *)input withWinLength:(NSUInteger)winLength {
	NSMutableOrderedSet *output = [NSMutableOrderedSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= winLength) {
			[output addObject:[NSNumber numberWithUnsignedInteger:range.location]];
		}
	}];

	return output;
}

// Look for indices in a range with a length greater than winLength and return an indexed set.
-(NSIndexSet *)findRangesIn:(NSIndexSet *)input withWinLength:(NSUInteger)winLength {
	NSMutableIndexSet *output = [NSMutableIndexSet new];

	[input enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {

		if (range.length >= winLength) {
			NSIndexSet *temp = [NSIndexSet indexSetWithIndexesInRange:range];
			[output addIndexes:temp];
		}
	}];

	return [output copy];
}

// Create a range to be queried using begin and end.
-(NSIndexSet *)makeInspectionWithRange:(NSUInteger)begin End:(NSUInteger)end {
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

//TESTING RANGE////////////////////////////////////////////////
//-(void)singleComparisonWith:(NSArray *)data
//				 IndexBegin:(NSUInteger)indexBegin
//				   IndexEnd:(NSUInteger)indexEnd
//				  Threshold:(float)threshold {
//
//	NSIndexSet *set1 = [self searchWithData:data
//									  Range:[self makeInspectionWithRange:indexBegin
//																	  End:indexEnd]
//									 Option:NSEnumerationConcurrent
//								 ComparisonBlock:(BOOL(^)(id o, NSUInteger i)) {
//									 return [self testGreaterThanWithThreshold:threshold withObject:o atIndex:i];
//								 }
//						];
//}
//
//-(NSIndexSet *)searchWithData:data
//						Range:(NSIndexSet *)range
//					   Option:(NSEnumerationOptions)option
//				   ComparisonBlock:(BOOL(^)(id o, NSUInteger idx))comparisonBlock {
//
//	return [data indexesOfObjectsAtIndexes:range
//								   options:option
//							   passingTest:^(id obj, NSUInteger idx, BOOL *stop){
//								   return comparisonBlock(obj, idx);
//							   }
//			];
//}
@end
