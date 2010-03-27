//
// BKBayesianTokenData.m
// Licensed under the terms of the BSD License, as specified below.
//

/*
 Copyright (c) 2010, Samuel Mendes
 
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 
 * Neither the name of ᐱ nor the names of its
 contributors may be used to endorse or promote products derived
 from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
 TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING 
 NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

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
