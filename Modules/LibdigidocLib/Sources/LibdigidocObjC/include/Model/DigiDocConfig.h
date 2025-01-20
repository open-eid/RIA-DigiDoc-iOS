#import <Foundation/Foundation.h>

@interface DigiDocConfig : NSObject


@property (assign, nonatomic) int logLevel;
@property (strong, nonatomic) NSString *logFile;

@property (strong, nonatomic) NSString *TSLCACHE;
@property (nonatomic, strong) NSString *SIVAURL;
@property (nonatomic, strong) NSString *TSLURL;
@property (nonatomic, strong) NSArray<NSString*> *TSLCERTS;
@property (nonatomic, strong) NSArray<NSString*> *LDAPCERTS;
@property (nonatomic, strong) NSString *TSAURL;
@property (nonatomic, strong) NSDictionary *OCSPISSUERS;

@property (nonatomic, strong) NSArray<NSString*> *CERTBUNDLE;

- (instancetype)initWithConf:(int)logLevel
                     logFile:(NSString *)logFile
                    TSLCache:(NSString *)TSLCache
                     SIVAURL:(NSString *)SIVAURL
                      TSLURL:(NSString *)TSLURL
                    TSLCERTS:(NSArray<NSString*> *)TSLCERTS
                   LDAPCERTS:(NSArray<NSString*> *)LDAPCERTS
                      TSAURL:(NSString *)TSAURL
                 OCSPISSUERS:(NSDictionary *)OCSPISSUERS
                  CERTBUNDLE:(NSArray<NSString*> *)CERTBUNDLE
                     TSACERT:(NSString *)TSACERT;

@end
