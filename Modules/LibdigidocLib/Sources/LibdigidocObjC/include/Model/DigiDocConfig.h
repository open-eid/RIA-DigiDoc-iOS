#import <Foundation/Foundation.h>

@interface DigiDocConfig : NSObject


@property (nonatomic, assign) int logLevel;
@property (nonatomic, strong) NSString *logFile;

@property (nonatomic, strong) NSString *TSLCACHE;
@property (nonatomic, strong) NSURL *SIVAURL;
@property (nonatomic, strong) NSURL *TSLURL;
@property (nonatomic, strong) NSArray<NSData *> *TSLCERTS;
@property (nonatomic, strong) NSArray<NSData *> *LDAPCERTS;
@property (nonatomic, strong) NSURL *TSAURL;
@property (nonatomic, strong) NSDictionary *OCSPISSUERS;
@property (nonatomic, strong) NSArray<NSData *> *CERTBUNDLE;

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSString *)SIVAURL
                      TSLURL:(NSString *)TSLURL
                    TSLCERTS:(NSArray<NSString*> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSString*> *)LDAPCERTS
                      TSAURL:(NSString *)TSAURL
                 OCSPISSUERS:(NSDictionary *)OCSPISSUERS
                  CERTBUNDLE:(NSArray<NSString*> *)CERTBUNDLE;

@end
