#import <Foundation/Foundation.h>
#import "DigiDocContainer.h"

@implementation DigiDocContainer

- (instancetype)initWithFileName:(NSString *)fileName
                        filePath:(NSString *)filePath
                       dataFiles:(NSArray<DigiDocDataFile *> *)dataFiles
                      signatures:(NSArray<DigiDocSignature *> *)signatures
                       mediatype:(NSString *)mediatype {
    self = [super init];
    if (self) {
        _fileName = [fileName copy];
        _filePath = [filePath copy];
        _dataFiles = [dataFiles copy];
        _signatures = [signatures copy];
        _mediatype = [mediatype copy];
    }
    return self;
}

@end
