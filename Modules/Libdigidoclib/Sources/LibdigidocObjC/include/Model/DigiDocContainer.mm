#import <Foundation/Foundation.h>
#import "DigiDocContainer.h"

@implementation DigiDocContainer

- (instancetype)initWithDataFiles:(NSArray<DigiDocDataFile *> *)dataFiles
                       signatures:(NSArray<DigiDocSignature *> *)signatures
                        mediaType:(NSString *)mediaType {
    self = [super init];
    if (self) {
        _dataFiles = [dataFiles copy];
        _signatures = [signatures copy];
        _mediatype = [mediaType copy];
    }
    return self;
}

@end
