//
//  Utils.h
//  BayesianKit
//
//  Created by Samuel Mendes on 3/27/10.
//  Copyright 2010 Atipic. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef APPNAME
#define APPNAME @"Bayes"
#endif

#ifndef VERSION
#define VERSION @"0.1"
#endif

#ifndef _
#define _(key) NSLocalizedString(key, nil)
#endif

#ifndef NSLocalizedLog
#define NSLocalizedLog(key, comment) NSLog(@"%@", NSLocalizedString(key, comment))
#endif

void PrintOut(NSString *format, ...);
