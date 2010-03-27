//
//  Bayes.m
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <BayesianKit/BKBayesianClassifier.h>
#import <BayesianKit/BKTokenizer.h>


@implementation BKBayesianClassifier

@synthesize pools;

- (id)init
{
    self = [super init];
    if (self) {
        corpus = [[BKBayesianDataPool alloc] initWithName:@"__Corpus__"];
        pools = [[NSMutableDictionary alloc] init];
        dirty = YES;
        
        _tokenizer = [[BKTokenizer alloc] init];
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
#pragma mark Serialization Methods
- (void)encodeWithCoder:(NSCoder*)coder
{
    [coder encodeObject:corpus forKey:@"Corpus"];
    [coder encodeObject:pools forKey:@"Pools"];
}

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super init];
    if (self) {
        _tokenizer = [[BKTokenizer alloc] init];
        dirty = YES;
        
        corpus = [[coder decodeObjectForKey:@"Corpus"] retain];
        pools = [[coder decodeObjectForKey:@"Pools"] retain];
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

- (BKBayesianClassifier*)classifierWithContentsOfFile:(NSString*)path
{
    return [[[BKBayesianClassifier alloc] initWithContentsOfFile:path] autorelease];
}

- (BOOL)writeToFile:(NSString*)path
{
    return [NSKeyedArchiver archiveRootObject:self toFile:path];
}

#pragma mark -
#pragma mark Pool Management
- (BKBayesianDataPool*)poolNamed:(NSString*)poolName
{
    BKBayesianDataPool *pool;
    pool = [pools objectForKey:poolName];
    
    if (pool == nil) {
        pool = [[[BKBayesianDataPool alloc] initWithName:poolName] autorelease];
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
    BKBayesianDataPool *sourcePool = [pools objectForKey:sourcePoolName];
    BKBayesianDataPool *destPool   = [pools objectForKey:destPoolName];
    
    if (!sourcePool || !destPool) return;
    
    for (NSString *token in sourcePool) {
        NSUInteger count = [sourcePool countForToken:token];
        [destPool addCount:count forToken:token];
    }
    
    dirty = YES;
}

#pragma mark -
#pragma mark Probabilities
- (void)stripToLevel:(NSUInteger)level
{
    for (NSString *token in [corpus allTokens]) {
        NSUInteger count = [corpus countForToken:token];
        
        if (count < level) {
            for (NSString *poolName in pools) {
                BKBayesianDataPool *pool = [pools objectForKey:poolName];
                [pool removeToken:token];
            }
            [corpus removeToken:token];
        }
    }
}
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
        BKBayesianDataPool *pool = [pools objectForKey:poolName];
        
        NSUInteger poolTotalCount = [pool tokensTotalCount];
        NSUInteger deltaTotalCount = MAX([corpus tokensTotalCount] - poolTotalCount, 1);
        
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
- (float)robinsonCombinerOnProbabilities:(NSArray*)probabilities
{
    NSUInteger length = [probabilities count];
    float nth = 1.0f / length;
    float probs[length], inverseProbs[length];
    
    NSUInteger idx = 0;
    for (NSNumber *probability in probabilities) {
        probs[idx] = [probability floatValue];
        inverseProbs[idx] = 1.0f - [probability floatValue];
        idx++;
    }
    
    float inverseProbsReduced = inverseProbs[0];
    float probsReduced = probs[0];
    for (int i = 1; i < length; i++) {
        inverseProbsReduced = inverseProbsReduced * inverseProbs[i];
        probsReduced = probsReduced * probs[i];
    }
    
    float P = 1.0f - powf(inverseProbsReduced, nth);
    float Q = 1.0f - powf(probsReduced, nth);
    
    float S = (P - Q) / (P + Q);
    return (1.0f + S) / 2.0f;
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
    NSArray *tokens = [_tokenizer tokenizeString:trainString];
    BKBayesianDataPool *pool = [self poolNamed:poolName];
    [self trainWithTokens:tokens inPool:pool];
    dirty = YES;
}

- (void)trainWithTokens:(NSArray*)tokens inPool:(BKBayesianDataPool*)pool
{
    for (NSString *token in tokens) {
        if (!token || [token isEqual:@""]) continue;
        [pool increaseCountForToken:token];
        [corpus increaseCountForToken:token];
    }
}

#pragma mark -
#pragma mark Classification Methods
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
    NSArray *tokens = [_tokenizer tokenizeString:string];
    [self updatePoolsProbabilities];
    
    NSMutableDictionary *result = [NSMutableDictionary dictionaryWithCapacity:42];
    for (NSString *poolName in pools) {
        BKBayesianDataPool *pool = [pools objectForKey:poolName];
        NSArray *tokensProbabilities = [pool probabilitiesForTokens:tokens];
        
        if ([tokensProbabilities count] > 0) {
            float probabilityCombined = [self robinsonCombinerOnProbabilities:tokensProbabilities];
            [result setObject:[NSNumber numberWithFloat:probabilityCombined] forKey:poolName];
        }
    }
    
    return result;
}

#pragma mark -
#pragma mark Classifier Informations
- (void)printInformations
{
    [self updatePoolsProbabilities];
    [corpus printInformations];
    for (NSString *poolName in pools) {
        [[pools objectForKey:poolName] printInformations];
    }
}

@end
