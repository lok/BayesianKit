//
//  Bayes.h
//  Bayesian
//
//  Created by Samuel Mendes on 3/26/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <BayesianKit/BKBayesianDataPool.h>
#import <BayesianKit/BKTokenizing.h>


@interface BKBayesianClassifier : NSObject<NSCoding> {
    BKBayesianDataPool *corpus;
    NSMutableDictionary *pools;
    BOOL dirty;
    
    @private
    id<BKTokenizing> _tokenizer;
}

@property (readonly) NSMutableDictionary *pools;

- (float)robinsonCombinerOnProbabilities:(NSArray*)probabilities;

- (void)updatePoolsProbabilities;
- (void)buildProbabilityCache;

- (void)trainWithFile:(NSString*)path forPoolNamed:(NSString*)poolName;
- (void)trainWithString:(NSString*)trainString forPoolNamed:(NSString*)poolName;
- (void)trainWithTokens:(NSArray*)tokens inPool:(BKBayesianDataPool*)pool;

- (void)stripToLevel:(NSUInteger)level;

- (NSDictionary*)guessWithString:(NSString*)string;
- (NSDictionary*)guessWithFile:(NSString*)path;

- (id)initWithContentsOfFile:(NSString*)path;
- (BKBayesianClassifier*)classifierWithContentsOfFile:(NSString*)path;
- (BOOL)writeToFile:(NSString*)path;

- (void)printInformations;

@end
