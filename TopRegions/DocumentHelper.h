//
//  DocumentHelper.h
//  TopRegions
//
//  Created by Martin Mandl on 25.05.14.
//  Copyright (c) 2014 m2m server software gmbh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentHelper : NSObject

+ (void)useDocumentWithOperation:(void (^)(UIManagedDocument *document, BOOL success))operation;

@end
