//
// BKBayesianClassifier.m
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

#import <BayesianKit/BKClassifier.h>
#import <BayesianKit/BKTokenizer.h>

NSString* const BKCorpusDataPoolName = @"__BKCorpus__";

@interface BKClassifier (Private)
+ (float)chiSquare:(float)chi withDegreeOfFreedom:(NSUInteger)df;
@end



@implementation BKClassifier

@synthesize pools;
@synthesize probabilitiesCombinerInvocation;
@synthesize tokenizer;

- (id)init
{
    self = [super init];
    if (self) {
        corpus = [[BKDataPool alloc] initWithName:BKCorpusDataPoolName];
        pools = [[NSMutableDictionary alloc] init];
        dirty = YES;
        
        [self setProbabilitiesCombinerWithTarget:self 
                                        selector:@selector(robinsonFisherCombinerOnProbabilities:userInfo:) 
                                        userInfo:nil];
        
        tokenizer = [[BKTokenizer alloc] init];
    }
    return self;
}

- (id)initWithContentsOfFile:(NSString*)path
{
    self = [[NSKeyedUnarchiver unarchiveObjectWithFile:path] retain];
    if (self) {
    }
    return self;
}


- (void)dealloc
{
    [corpus release];
    [pools release];
    [super dealloc];
}

#pragma mark -
#pragma mark NSCoding Methods
- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        tokenizer = [[BKTokenizer alloc] init];
        dirty = YES;
        
        corpus = [[coder decodeObjectForKey:@"Corpus"] retain];
        pools = [[coder decodeObjectForKey:@"Pools"] retain];
        
        [self setProbabilitiesCombinerWithTarget:self 
                                        selector:@selector(robinsonFisherCombinerOnProbabilities:userInfo:) 
                                        userInfo:nil];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:corpus forKey:@"Corpus"];
    [coder encodeObject:pools forKey:@"Pools"];
}

#pragma mark -
#pragma mark Creation Methods
- (BKClassifier*)classifierWithContentsOfFile:(NSString*)path
{
    return [[[BKClassifier alloc] initWithContentsOfFile:path] autorelease];
}

#pragma mark -
#pragma mark Saving Methods
- (BOOL)writeToFile:(NSString*)path
{
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

#pragma mark -
#pragma mark Pool Management
- (BKDataPool*)poolNamed:(NSString*)poolName
{
    BKDataPool *pool;
    pool = [pools objectForKey:poolName];
    
    if (pool == nil) {
        pool = [[[BKDataPool alloc] initWithName:poolName] autorelease];
        [pools setObject:pool forKey:poolName];
        dirty = YES;
    }
    return pool;
}

- (void)removePoolNamed:(NSString*)poolName
{
    [pools removeObjectForKey:poolName];
    dirty = YES;
}

- (void)mergePoolNamed:(NSString*)sourcePoolName withPoolNamed:(NSString*)destPoolName
{
    BKDataPool *sourcePool = [pools objectForKey:sourcePoolName];
    BKDataPool *destPool   = [pools objectForKey:destPoolName];
    
    if (!sourcePool || !destPool) return;
    
    for (NSString *token in sourcePool) {
        NSUInteger count = [sourcePool countForToken:token];
        [destPool addCount:count forToken:token];
    }
    
    dirty = YES;
}

#pragma mark -
#pragma mark Probabilities
- (void)updatePoolsProbabilities
{
    if (dirty) {
        [self buildProbabilityCache];
        dirty = NO;
    }
}

- (void)buildProbabilityCache
{
    for (NSString *poolName in pools) {
        BKDataPool *pool = [pools objectForKey:poolName];
        
        NSUInteger poolTotalCount = [pool tokensTotalCount];
        NSUInteger deltaTotalCount = MAX([corpus tokensTotalCount] - poolTotalCount, 1u);
        
        for (NSString *token in pool) {
            NSUInteger corpusCount = [corpus countForToken:token];
            NSUInteger poolCount   = [pool countForToken:token];
            NSUInteger deltaCount  = corpusCount - poolCount;
            
            float goodMetric;
            if (poolTotalCount == 0) {
                goodMetric = 1.f;
            } else {
                goodMetric = MIN(1.f, (float)deltaCount/(float)poolTotalCount);
            }
            float badMetric = MIN(1.f, (float)poolCount/(float)deltaTotalCount);
            float f = badMetric / (goodMetric + badMetric);
            
            if (fabs(f - 0.5f) >= 0.1) [pool setProbability:f forToken:token];
        }
    }
}

#pragma mark -
#pragma mark Combiners
- (void)setProbabilitiesCombinerWithTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo
{
    SEL signatureSelector = @selector(robinsonCombinerOnProbabilities:userInfo:);
    NSMethodSignature *signature = [BKClassifier instanceMethodSignatureForSelector:signatureSelector];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];

    [invocation setTarget:target];
    [invocation setSelector:selector];
    [invocation setArgument:&userInfo atIndex:3];
    [invocation retainArguments];

    [self setProbabilitiesCombinerInvocation:invocation];
}

- (float)robinsonCombinerOnProbabilities:(NSArray*)probabilities userInfo:(id) __unused userInfo
{
    NSUInteger length = [probabilities count];
    float nth = 1.0f / (uint32_t)length;
    float probs[length], inverseProbs[length];
    
    NSUInteger idx = 0;
    for (NSNumber *probability in probabilities) {
        probs[idx] = [probability floatValue];
        inverseProbs[idx] = 1.0f - [probability floatValue];
        idx++;
    }
    
    float inverseProbsReduced = inverseProbs[0];
    float probsReduced = probs[0];
    for (NSUInteger i = 1; i < length; i++) {
        inverseProbsReduced = inverseProbsReduced * inverseProbs[i];
        probsReduced = probsReduced * probs[i];
    }
    
    float P = 1.0f - powf(inverseProbsReduced, nth);
    float Q = 1.0f - powf(probsReduced, nth);
    
    float S = (P - Q) / (P + Q);
    return (1.0f + S) / 2.0f;
}

- (float)robinsonFisherCombinerOnProbabilities:(NSArray*)probabilities userInfo:(id) __unused userInfo
{
    NSUInteger length = [probabilities count];
    float probs[length], inverseProbs[length];
    
    if (length > (NSUIntegerMax / 2)) { 
        @throw [NSException exceptionWithName:@"NSUInteger overflow" 
                                       reason:@"Too much probabilities to be combined" 
                                     userInfo:nil];
    }
    
    NSUInteger idx = 0;
    for (NSNumber *probability in probabilities) {
        probs[idx] = [probability floatValue];
        inverseProbs[idx] = (1.0f - [probability floatValue]);
        idx++;
    }
    
    float inverseProbsReduced = inverseProbs[0];
    float probsReduced = probs[0];
    for (NSUInteger i = 1; i < length; i++) {
        inverseProbsReduced = inverseProbsReduced * inverseProbs[i];
        probsReduced = probsReduced * probs[i];
    }
    
    float H = [BKClassifier chiSquare:(-2.0f * logf(probsReduced)) withDegreeOfFreedom:(2 * length)];
    float S = [BKClassifier chiSquare:(-2.0f * logf(inverseProbsReduced)) withDegreeOfFreedom:(2 * length)];
    
    return (1.0f + H - S) / 2.0f;
}

#pragma mark -
#pragma mark Trainning Methods
- (void)trainWithFile:(NSString*)path forPoolNamed:(NSString*)poolName
{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path 
                                                  encoding:NSUTF8StringEncoding 
                                                     error:&error];
    if (error) {
        NSLog(@"Error - %@", [error localizedDescription]);
        return;
    }
    [self trainWithString:content forPoolNamed:poolName];
}

- (void)trainWithString:(NSString*)trainString forPoolNamed:(NSString*)poolName
{
    NSArray *tokens = [tokenizer tokenizeString:trainString];
    BKDataPool *pool = [self poolNamed:poolName];
    [self trainWithTokens:tokens inPool:pool];
    dirty = YES;
}

- (void)trainWithTokens:(NSArray*)tokens inPool:(BKDataPool*)pool
{
    for (NSString *token in tokens) {
        if (!token || [token isEqual:@""]) continue;
        [pool increaseCountForToken:token];
        [corpus increaseCountForToken:token];
    }
}

#pragma mark -
#pragma mark Guessing Methods
- (NSDictionary*)guessWithFile:(NSString*)path
{
    NSError *error = nil;
    NSString *content = [NSString stringWithContentsOfFile:path 
                                                  encoding:NSUTF8StringEncoding 
                                                     error:&error];
    if (error) {
        NSLog(@"Error - %@", [error localizedDescription]);
        return nil;
    }
    return [self guessWithString:content];
}

- (NSDictionary*)guessWithString:(NSString*)string
{
    NSArray *tokens = [tokenizer tokenizeString:string];
    [self updatePoolsProbabilities];
    return [self guessWithTokens:tokens];
}

- (NSDictionary*)guessWithTokens:(NSArray*)tokens
{
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:[pools count]];
    
    for (NSString *poolName in pools) {
        BKDataPool *pool = [pools objectForKey:poolName];
        NSArray *tokensProbabilities = [pool probabilitiesForTokens:tokens];
        
        if ([tokensProbabilities count] > 0) {
            float probabilityCombined;
            [probabilitiesCombinerInvocation setArgument:&tokensProbabilities atIndex:2];
            [probabilitiesCombinerInvocation invoke];
            [probabilitiesCombinerInvocation getReturnValue:&probabilityCombined];
            [result setObject:[NSNumber numberWithFloat:probabilityCombined]
                       forKey:poolName];
        }
    }
    
    return result;
}

#pragma mark -
#pragma mark Sanitizing Methods
- (void)stripToLevel:(NSUInteger)level
{
    for (NSString *token in [corpus allTokens]) {
        NSUInteger count = [corpus countForToken:token];
        
        if (count < level) {
            for (NSString *poolName in pools) {
                BKDataPool *pool = [pools objectForKey:poolName];
                [pool removeToken:token];
            }
            [corpus removeToken:token];
        }
    }
}

#pragma mark -
#pragma mark Printing Methods
- (void)printInformations
{
    [self updatePoolsProbabilities];
    [corpus printInformations];
    for (NSString *poolName in pools) {
        [[pools objectForKey:poolName] printInformations];
    }
}

#pragma mark -
#pragma mark Private Methods
+ (float)chiSquare:(float)chi withDegreeOfFreedom:(NSUInteger)df
{
    float m = chi / 2.0f;
    float sum, term;
    
    if ((df & 1) == 1) return -1.0f;
    
    sum = term = expf(-m);
    for (NSUInteger i = 1; i < (df / 2); i++) {
        term *= m/(int32_t)i;
        sum += term;
    }
    
    return MIN(sum, 1.0f);
}


@end
