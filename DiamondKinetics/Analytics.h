//
//  Analytics.h
//  DiamondKinetics
//
//  Created by Daniel J. Pinter on 2019-02-15.
//  Copyright © 2019 DataZombies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Analytics : NSObject

// From ​indexBegin​ to ​indexEnd​, search data for values that are higher than
// threshold​. Return the first index where data has values that meet this
// criteria for at least winLength​ samples.
-(NSUInteger)searchContinuityAboveValue:(NSArray *)data
							 indexBegin:(NSUInteger)indexBegin
							   indexEnd:(NSUInteger)indexEnd
							  threshold:(float)threshold
							  winLength:(NSUInteger)winLength;

// From ​indexBegin​ to ​indexEnd​ (where indexBegin​ is larger than ​indexEnd​),
// search data for values that are higher than thresholdLo​ and lower than
// thresholdHi​. Return the first index where data has values that meet this
// criteria for at least ​winLength​ samples. Return the first *encountered*
// index.
-(NSUInteger)backSearchContinuityWithinRange:(NSArray *)data
								  indexBegin:(NSUInteger)indexBegin
									indexEnd:(NSUInteger)indexEnd
								 thresholdLo:(float)thresholdLo
								 thresholdHi:(float)thresholdHi
								   winLength:(NSUInteger)winLength;

// From ​indexBegin​ to ​indexEnd​, search ​data1​ for values that are higher than
// threshold1​ and also search ​data2​ for values that are higher than ​threshold2​.
// Return the first index where both ​data1​ and ​data2​ have values that meet these
// criteria for at least ​winLength​ samples.
-(NSUInteger)searchContinuityAboveValueTwoSignals:(NSArray *)data1
											data2:(NSArray *)data2
									   indexBegin:(NSUInteger)indexBegin
										 indexEnd:(NSUInteger)indexEnd
									   threshold1:(float)threshold1
									   threshold2:(float)threshold2
										winLength:(NSUInteger)winLength;

// From ​indexBegin​ to ​indexEnd​, search data for values that are higher than
// thresholdLo​ and lower than ​thresholdHi​. Return the the starting index and
// ending index of all continuous samples that meet this criteria for at least
// winLength​ data points.
-(NSOrderedSet *)searchMultiContinuityWithinRange:(NSArray *)data
									   indexBegin:(NSUInteger)indexBegin
										 indexEnd:(NSUInteger)indexEnd
									  thresholdLo:(float)thresholdLo
									  thresholdHi:(float)thresholdHi
										winLength:(NSUInteger)winLength;

@end

NS_ASSUME_NONNULL_END

