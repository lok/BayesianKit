//
//  BayesianData.h
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BKBayesianTokenData : NSObject <NSCoding> {
    NSUInteger count;
    float probability;
}

@property (readwrite, assign) NSUInteger count;
@property (readwrite, assign) float probability;

- (id)initWithCount:(NSUInteger)aCount;
+ (BKBayesianTokenData*)tokenDataWithCount:(NSUInteger)aCount;

- (NSComparisonResult)compareCount:(BKBayesianTokenData*)other;
- (NSComparisonResult)compareProbability:(BKBayesianTokenData*)other;

@end
