//
//  BKBayesianTokenDataTest.m
//  BayesianKit
//
//  Created by Samuel Mendes on 3/28/10.
//  Copyright 2010 Atipic. All rights reserved.
//

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
