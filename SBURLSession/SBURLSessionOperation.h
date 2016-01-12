

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^OnCompletion)(id data);
typedef void (^OnSuccess)(NSString *responseString);
typedef void (^OnFailure)(NSError *error);
typedef void (^OnParseComplete)(NSDictionary *root);
typedef void (^OnXMLParseComplete)(NSMutableArray *root);

@interface SBURLSessionOperation : NSOperation < NSURLSessionDelegate, NSURLSessionDataDelegate, NSURLSessionTaskDelegate > {
    NSMutableData *webData;
    NSInteger expectedLength;
    NSInteger downloadedLength;
    OnSuccess onSuccess;
    OnFailure onFailure;
    OnParseComplete onParseComplete;
    NSURLCredential *requestCredential;
    NSMutableArray *domains;
    NSInteger count;
    NSMutableDictionary *_headers;
}

@property (nonatomic) CGFloat timeout;
@property (nonatomic) BOOL usesCache;
@property (nonatomic) NSInteger responseCode;
@property (nonatomic) BOOL bubbleHTTP400;

- (void)addCertificateDomains:(NSString *)domain, ...NS_REQUIRES_NIL_TERMINATION;

- (void)executeJSONGet:(NSString *)url onSuccess:(OnSuccess)success onFailure:(OnFailure)failure;
- (void)executeJSONPut:(NSString *)url requestBody:(NSData *)requestBody onSuccess:(OnSuccess)success onFailure:(OnFailure)failure;
- (void)executeJSONPost:(NSString *)url requestBody:(NSData *)requestBody onSuccess:(OnSuccess)success onFailure:(OnFailure)failure;
- (void)executeJSONDelete:(NSString *)url onSuccess:(OnSuccess)success onFailure:(OnFailure)failure;

- (void)parseJSON:(NSString *)data onParseComplete:(OnParseComplete)parseComplete;
- (void)setHeaders:(NSDictionary *)headers;



@end
