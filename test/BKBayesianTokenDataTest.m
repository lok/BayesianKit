//
// BKBayesianTokenDataTest.m
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

#import "BKBayesianTokenDataTest.h"


@implementation BKBayesianTokenDataTest

- (void)setUp
{
    data = [[BKBayesianTokenData alloc] initWithCount:42];
    [data setProbability:0.42f];
}

- (void)tearDown
{
    [data release];
}

- (void)testInitialization
{
    STAssertNotNil(data, @"Could not create BKBayesianTokenData");
}

- (void)testCreation
{
    BKBayesianTokenData *tokenData = [BKBayesianTokenData tokenDataWithCount:42];
    STAssertNotNil(tokenData, @"Could not create BKBayesianTokenData");
    STAssertEquals([tokenData count], (NSUInteger)42, @"Creation did not use the right count amount");
}

- (void)testCountComparison
{
    BKBayesianTokenData *alpha = [BKBayesianTokenData tokenDataWithCount:0];
    BKBayesianTokenData *beta  = [BKBayesianTokenData tokenDataWithCount:42];
    BKBayesianTokenData *gamma = [BKBayesianTokenData tokenDataWithCount:NSUIntegerMax];
 
    STAssertEquals([alpha compareCount:data],
                   (NSComparisonResult)NSOrderedAscending,
                   @"Count comparison is not right");
    STAssertEquals([beta compareCount:data],
                   (NSComparisonResult)NSOrderedSame,
                   @"Count comparison is not right");
    STAssertEquals([gamma compareCount:data],
                   (NSComparisonResult)NSOrderedDescending,
                   @"Count comparison is not right");
}

- (void)testProbabilityComparison
{
    BKBayesianTokenData *alpha = [BKBayesianTokenData tokenDataWithCount:0];
    BKBayesianTokenData *beta  = [BKBayesianTokenData tokenDataWithCount:42];
    BKBayesianTokenData *gamma = [BKBayesianTokenData tokenDataWithCount:NSUIntegerMax];
    
    [alpha setProbability:0.00f];
    [beta  setProbability:0.42f];
    [gamma setProbability:1.00f];
    
    STAssertEquals([alpha compareProbability:data],
                   (NSComparisonResult)NSOrderedAscending,
                   @"Probability comparison is not right");
    STAssertEquals([beta compareProbability:data],
                   (NSComparisonResult)NSOrderedSame,
                   @"Probability comparison is not right");
    STAssertEquals([gamma compareProbability:data],
                   (NSComparisonResult)NSOrderedDescending,
                   @"Probability comparison is not right");
}

- (void)testCountProperty
{
    STAssertEquals([data count], (NSUInteger)42, @"Count property not working properly");
}

- (void)testProbabilityProperty
{
    STAssertEquals([data probability], (float)0.42f, @"Probability property not working properly");
}

@end
