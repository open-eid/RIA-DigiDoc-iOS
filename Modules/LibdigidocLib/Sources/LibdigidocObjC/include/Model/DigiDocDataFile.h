// SPDX-FileCopyrightText: Estonian Information System Authority
// SPDX-License-Identifier: LGPL-2.1-or-later

#import <Foundation/Foundation.h>

@interface DigiDocDataFile : NSObject

@property (nonatomic, strong) NSString *fileId;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, assign) long fileSize;
@property (nonatomic, strong) NSString *mediaType;

@end

