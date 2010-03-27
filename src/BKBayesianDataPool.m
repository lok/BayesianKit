//
// BKBayesianDataPool.m
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

#import <BayesianKit/BKBayesianDataPool.h>
#import <BayesianKit/BKBayesianTokenData.h>


@implementation BKBayesianDataPool

@synthesize _tokensTotalCount;

- (id)initWithName:(NSString*)aName
{
    self = [super init];
    if (self) {
        name = [aName retain];
        _tokensCount = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        name = [[coder decodeObjectForKey:@"Name"] retain];
        _tokensTotalCount = [coder decodeIntegerForKey:@"TotalCount"];
        _tokensCount = [[coder decodeObjectForKey:@"Tokens"] retain];
    }
    return self;
}

- (void)dealloc
{
    [name release];
    [_tokensCount release];
    [super dealloc];
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:name forKey:@"Name"];
    [coder encodeInteger:_tokensTotalCount forKey:@"TotalCount"];
    [coder encodeObject:_tokensCount forKey:@"Tokens"];
}

#pragma mark -
#pragma mark Token Counting Methods
- (void)removeToken:(NSString*)token
{
    _tokensTotalCount -= [self countForToken:token];
    [_tokensCount removeObjectForKey:token];
}

- (NSUInteger)countForToken:(NSString*)token
{
    BKBayesianTokenData *data = [_tokensCount objectForKey:token];
    if (data) {
        return [data count];
    } else {
        return 0;
    }
}

- (void)setCount:(NSUInteger)count forToken:(NSString*)token
{
    _tokensTotalCount -= [self countForToken:token];
    [_tokensCount setObject:[BKBayesianTokenData tokenDataWithCount:count] 
                     forKey:token];
    _tokensTotalCount += count;
}

- (void)addCount:(NSUInteger)count forToken:(NSString*)token
{
    BKBayesianTokenData *data = [_tokensCount objectForKey:token];
    if (!data) {
        data = [BKBayesianTokenData tokenDataWithCount:count];
    } else {
        if ((NSUIntegerMax - count) < [data count]) {
            @throw [NSException exceptionWithName:@"NSUInteger overflow" 
                                           reason:@"If token count is too high" 
                                         userInfo:nil];
        }
        data = [BKBayesianTokenData tokenDataWithCount:(count + [data count])];
    }
    _tokensTotalCount+=count;
    [_tokensCount setObject:data forKey:token];
}

- (void)increaseCountForToken:(NSString*)token
{
    NSUInteger count = [self countForToken:token];
    [_tokensCount setObject:[BKBayesianTokenData tokenDataWithCount:count+1]
                     forKey:token];
    _tokensTotalCount++;
}

#pragma mark -
#pragma mark Token Probabilities Methods
- (float)probabilityForToken:(NSString*)token
{
    BKBayesianTokenData *data = [_tokensCount objectForKey:token];
    if (data) {
        return [data probability];
    } else {
        return 0.0f;
    }
}

- (void)setProbability:(float)probability forToken:(NSString*)token
{
    BKBayesianTokenData *data = [_tokensCount objectForKey:token];
    if (data) {
        [data setProbability:probability];
    }
}

- (NSArray*)probabilitiesForTokens:(NSArray*)tokens
{
    NSMutableArray *probabilities = [NSMutableArray arrayWithCapacity:[tokens count]];
    
    for (NSString *token in tokens) {
        float probability = [self probabilityForToken:token];
        if (probability > 0) {
            [probabilities addObject:[NSNumber numberWithFloat:probability]];
        }
    }
    [probabilities sortUsingSelector:@selector(compare:)];
    
    return probabilities;
}

#pragma mark -
#pragma mark Misc
- (NSArray*)allTokens
{
    return [_tokensCount allKeys];
}

- (NSString*)description
{
    return [_tokensCount description];
}

- (void)printInformations
{
    NSLog(@"%@ Informations:", name);
    NSLog(@"         Number of tokens: %llu", [_tokensCount count]);
    NSLog(@"    Total count of tokens: %llu", _tokensTotalCount);
    
    NSArray *keys = [_tokensCount keysSortedByValueUsingSelector:@selector(compareCount:)];
    NSString *token = [keys lastObject];
    NSLog(@"       Most counted token: %@ counted %llu times", token, [self countForToken:token]);
    
    keys = [_tokensCount keysSortedByValueUsingSelector:@selector(compareProbability:)];
    token = [keys lastObject];
    NSLog(@"Highest probability token: %@ with %02i%%", token, (int)([self probabilityForToken:token]*100.));
}

#pragma mark -
#pragma mark Fast Enumeration Methods
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id *)stackbuf count:(NSUInteger)len
{
    return [_tokensCount countByEnumeratingWithState:state objects:stackbuf count:len];
}

@end
