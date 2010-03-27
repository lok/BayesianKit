//
//  BayesianData.m
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <BayesianKit/BKBayesianTokenData.h>


@implementation BKBayesianTokenData

@synthesize count;
@synthesize probability;

- (id)initWithCount:(NSUInteger)aCount
{
    self = [super init];
    if (self) {
        [self setCount:aCount];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        count = [coder decodeIntegerForKey:@"Count"];
        probability = [coder decodeFloatForKey:@"Probability"];
    }
    return self;
}

+ (BKBayesianTokenData*)tokenDataWithCount:(NSUInteger)aCount
{
    return [[[BKBayesianTokenData alloc] initWithCount:aCount] autorelease];
}

- (void)setProbability:(float)aProbability
{
    probability = MAX(0.0001f, MIN(0.9999f, aProbability));
}

- (NSString*)description
{
    return [NSString stringWithFormat:@"{count: %llu, probability: %f}", count, probability];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeInteger:count forKey:@"Count"];
    [coder encodeFloat:probability forKey:@"Probability"];
}

- (NSComparisonResult)compareCount:(BKBayesianTokenData*)other
{
    return [[NSNumber numberWithUnsignedInteger:count] compare:
            [NSNumber numberWithUnsignedInteger:[other count]]];
}

- (NSComparisonResult)compareProbability:(BKBayesianTokenData*)other
{
    return [[NSNumber numberWithFloat:probability] compare:
            [NSNumber numberWithFloat:[other probability]]];
}

@end
