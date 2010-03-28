//
// BKBayesianDataPool.h
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

#import "BKBayesianDataPoolTest.h"


@implementation BKBayesianDataPoolTest

- (void)setUp
{
    pool = [[BKBayesianDataPool alloc] initWithName:@"TestPool"];
}

- (void)tearDown
{
    [pool release];
}

- (void)testInitialization
{
    STAssertNotNil(pool, @"Could not create a BKBayesianDataPool");
    STAssertEqualObjects([pool name], @"TestPool", @"Name property not respected during init");
}

- (void)testCountForToken
{
    STAssertEquals([pool countForToken:@"Marvin"], (NSUInteger)0, @"Token count incorrect");
    [pool setCount:42 forToken:@"Marvin"];
    STAssertEquals([pool countForToken:@"Marvin"], (NSUInteger)42, @"Token count incorrect");
    [pool addCount:42 forToken:@"Marvin"];
    STAssertEquals([pool countForToken:@"Marvin"], (NSUInteger)84, @"Token count incorrect");
    [pool increaseCountForToken:@"Marvin"];
    STAssertEquals([pool countForToken:@"Marvin"], (NSUInteger)85, @"Token count incorrect");
}

- (void)testProbabilityForToken
{
    STAssertEquals([pool probabilityForToken:@"Marvin"], 0.00f, @"Token probability incorrect");
    [pool setProbability:0.42f forToken:@"Marvin"];
    STAssertEquals([pool probabilityForToken:@"Marvin"], 0.00f, @"Token probability should not exists");
    
    [pool setCount:42 forToken:@"Marvin"];
    [pool setProbability:0.42f forToken:@"Marvin"];
    STAssertEquals([pool probabilityForToken:@"Marvin"], 0.42f, @"Token probability incorrect");
    
    [pool setProbability:MAXFLOAT forToken:@"Marvin"];
    STAssertEquals([pool probabilityForToken:@"Marvin"], 0.9999f, @"Token maximum probability is higher than 99%");

    [pool setProbability:-MAXFLOAT forToken:@"Marvin"];
    STAssertEquals([pool probabilityForToken:@"Marvin"], 0.0001f, @"Token minimum probability is higher than 01%");
}
@end
