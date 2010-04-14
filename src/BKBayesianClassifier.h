//
// BKBayesianClassifier.h
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

#import <Foundation/Foundation.h>

#import <BayesianKit/BKBayesianDataPool.h>
#import <BayesianKit/BKTokenizing.h>


/**
  Pool name for the corpus' pool
 */
extern const NSString *BKCorpusDataPoolName;

/**
  Naive bayesian classifier class.
 
  More blabla
 */
@interface BKBayesianClassifier : NSObject<NSCoding> {
    BKBayesianDataPool *corpus;
    /**
      Data pools indexed by theirs names
     */
    NSMutableDictionary *pools;
    BOOL dirty;
    
    NSInvocation *probabilitiesCombinerInvocation;
    
    id<BKTokenizing> tokenizer;
}

@property (readonly) NSMutableDictionary *pools;
@property (readwrite, retain) NSInvocation *probabilitiesCombinerInvocation;
@property (readwrite, retain) id<BKTokenizing> tokenizer;


/**
  Initialize a bayesian classifier using a previous training saved in a file
  @param path The path to the file containing the classifier's save
  @returns A bayesian classifier initialized
 */
- (id)initWithContentsOfFile:(NSString*)path;

/**
	Create a new classifier using a previous training saved in a file
	@param path The path to the file containing the classifier's save
	@returns A new bayesian classifier
 */
- (BKBayesianClassifier*)classifierWithContentsOfFile:(NSString*)path;

- (BOOL)writeToFile:(NSString*)path;

- (BKBayesianDataPool*)poolNamed:(NSString*)poolName;
- (void)removePoolNamed:(NSString*)poolName;
- (void)mergePoolNamed:(NSString*)sourcePoolName withPoolNamed:(NSString*)destPoolName;

- (void)updatePoolsProbabilities;
- (void)buildProbabilityCache;

- (void)setProbabilitiesCombinerWithTarget:(id)target selector:(SEL)selector userInfo:(id)userInfo;
- (float)robinsonCombinerOnProbabilities:(NSArray*)probabilities userInfo:(id)userInfo;
- (float)robinsonFisherCombinerOnProbabilities:(NSArray*)probabilities userInfo:(id)userInfo;

- (void)trainWithFile:(NSString*)path forPoolNamed:(NSString*)poolName;
- (void)trainWithString:(NSString*)trainString forPoolNamed:(NSString*)poolName;
- (void)trainWithTokens:(NSArray*)tokens inPool:(BKBayesianDataPool*)pool;

- (NSDictionary*)guessWithString:(NSString*)string;
- (NSDictionary*)guessWithFile:(NSString*)path;
- (NSDictionary*)guessWithTokens:(NSArray*)tokens;

- (void)stripToLevel:(NSUInteger)level;

- (void)printInformations;

@end
