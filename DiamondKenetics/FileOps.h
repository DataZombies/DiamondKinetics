//
//  FileOps.h
//  DiamondKenetics
//
//  Created by Daniel J. Pinter on 2019-02-15.
//  Copyright © 2019 DataZombies. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FileOps : NSObject

+(id)sharedFileOpsManager;

@property (strong, nonatomic) NSDictionary *swingData;

@end

NS_ASSUME_NONNULL_END
