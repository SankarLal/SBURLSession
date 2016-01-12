

#import "SBURLSessionOperation.h"

@implementation SBURLSessionOperation

@synthesize timeout = _timeout;
@synthesize usesCache = _usesCache;
@synthesize responseCode = _responseCode;
@synthesize bubbleHTTP400 = _bubbleHTTP400;


- (void)setHeaders:(NSMutableDictionary *)headers {
    _headers = headers;
}

- (void)executeJSONGet:(NSString *)url onSuccess:(OnSuccess)success onFailure:(OnFailure)failure {
   
    onSuccess = success;
    onFailure = failure;
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    NSMutableURLRequest __autoreleasing *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters: set]]
                                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                            timeoutInterval:60];
    
    
    [request setHTTPMethod:@"GET"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
    
    
}

- (void)executeJSONPost:(NSString *)url requestBody:(NSData *)requestBody onSuccess:(OnSuccess)success onFailure:(OnFailure)failure {
    
    onSuccess = success;
    onFailure = failure;
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    NSMutableURLRequest __autoreleasing *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters: set]]
                                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                            timeoutInterval:60];
    [request setHTTPMethod:@"POST"];
    [request setHTTPBody:requestBody];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
    
}

- (void)executeJSONPut:(NSString *)url requestBody:(NSData *)requestBody onSuccess:(OnSuccess)success onFailure:(OnFailure)failure {
    
    onSuccess = success;
    onFailure = failure;
    
    NSMutableURLRequest __autoreleasing *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]
                                                                                cachePolicy:(_usesCache == YES) ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData
                                                                            timeoutInterval:_timeout];
    [request setHTTPMethod:@"PUT"];
    [request setHTTPBody:requestBody];
    
    [request addValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
    
}
- (void)executeJSONDelete:(NSString *)url onSuccess:(OnSuccess)success onFailure:(OnFailure)failure {
    onSuccess = success;
    onFailure = failure;
    
    NSCharacterSet *set = [NSCharacterSet URLQueryAllowedCharacterSet];
    
    NSMutableURLRequest __autoreleasing *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[url stringByAddingPercentEncodingWithAllowedCharacters: set]]
                                                                                cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                            timeoutInterval:60];
    [request setHTTPMethod:@"DELETE"];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    NSURLSessionTask *task = [session dataTaskWithRequest:request];
    [task resume];
    
}

- (void)addCertificateDomains:(NSString *)domain, ... {
    va_list args;
    va_start(args, domain);
    
    for (NSString *arg = domain; arg != nil; arg = va_arg(args, NSString *)) {
        [domains addObject:arg];
    }
    
    va_end(args);
}

#pragma mark - Private methods

- (BOOL)isDomainAuthenticated:(NSString *)host {
    for (NSString *domain in domains) {
        if ([host hasSuffix:domain]) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - NSURLSession Data Delegate Function
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSHTTPURLResponse __autoreleasing *httpResponse = (NSHTTPURLResponse *)response;
    assert([httpResponse isKindOfClass:[NSHTTPURLResponse class]]);
    _responseCode = httpResponse.statusCode;
    
    if (httpResponse.statusCode == 400 && _bubbleHTTP400 == YES) {
        NSMutableDictionary __autoreleasing *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSString stringWithFormat:@"Incorrect response code %ld received.", (long)httpResponse.statusCode] forKey:NSLocalizedDescriptionKey];
        [userInfo setValue:dataTask.originalRequest.URL.absoluteString forKey:NSURLErrorFailingURLStringErrorKey];
        
        NSError __autoreleasing *error = [[NSError alloc] initWithDomain:dataTask.originalRequest.URL.host code:-10400 userInfo:userInfo];
        
        if (onFailure) {
            onFailure(error);
            
            onFailure = nil;
        }
        
        userInfo = nil;
        error = nil;
                
        return;
    }
    
    if (httpResponse.statusCode != 200 && httpResponse.statusCode != 401) {
        NSMutableDictionary __autoreleasing *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSString stringWithFormat:@"Incorrect response code %ld received.", (long)httpResponse.statusCode] forKey:NSLocalizedDescriptionKey];
        [userInfo setValue:dataTask.originalRequest.URL.absoluteString forKey:NSURLErrorFailingURLStringErrorKey];
        
        NSError __autoreleasing *error = [[NSError alloc] initWithDomain:dataTask.originalRequest.URL.host code:-10001 userInfo:userInfo];
        
        if (onFailure) {
            onFailure(error);
            
            onFailure = nil;
        }
        
        userInfo = nil;
        error = nil;
        
    }
    
    webData = [[NSMutableData alloc] init];
    
    expectedLength = response.expectedContentLength;
    downloadedLength = 0;
    
    completionHandler (NSURLSessionResponseAllow);
}

-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    [webData appendData:data];
    downloadedLength = downloadedLength + [data length];

}


-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential * _Nullable))completionHandler {
    
    if (requestCredential) {
        [[challenge sender] useCredential:requestCredential forAuthenticationChallenge:challenge];
    } else {
        if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
            if ([self isDomainAuthenticated:challenge.protectionSpace.host] == YES) {
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            } else {
                NSMutableDictionary __autoreleasing *userInfo = [NSMutableDictionary dictionary];
                [userInfo setValue:@"Authorization required." forKey:NSLocalizedDescriptionKey];
                [userInfo setValue:task.originalRequest.URL.absoluteString forKey:NSURLErrorFailingURLStringErrorKey];
                
                NSError __autoreleasing *error = [[NSError alloc] initWithDomain:task.originalRequest.URL.host code:-10001 userInfo:userInfo];
                
                if (onFailure) {
                    onFailure(error);
                    
                    onFailure = nil;
                }
                
                userInfo = nil;
                error = nil;
                
            }
        }
    }
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
   
    if (expectedLength > 0 && downloadedLength != expectedLength) {
        NSMutableDictionary __autoreleasing *userInfo = [NSMutableDictionary dictionary];
        [userInfo setValue:[NSString stringWithFormat:@"Downloaded %ld bytes when expecting %ld bytes.", (long)downloadedLength, (long)expectedLength] forKey:NSLocalizedDescriptionKey];
        [userInfo setValue:task.originalRequest.URL.absoluteString forKey:NSURLErrorFailingURLStringErrorKey];
        
        NSError __autoreleasing *error = [[NSError alloc] initWithDomain:task.originalRequest.URL.host code:-10002 userInfo:userInfo];
        
        if (onFailure) {
            onFailure(error);
            
            onFailure = nil;
        }
        
        userInfo = nil;
        error = nil;
        
        return;
    }
    
    NSString __autoreleasing *responseString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    if (responseString == nil) {
        NSString __autoreleasing *tempString = [[NSString alloc] initWithData:webData encoding:NSASCIIStringEncoding];
        responseString = tempString;
    }
    if (onSuccess) {
        onSuccess(responseString);
        
        onSuccess = nil;
    }

}

- (void)parseJSON:(NSString *)data onParseComplete:(OnParseComplete)parseComplete {
    onParseComplete = parseComplete;
    
    NSError __autoreleasing *error = nil;
    NSData __autoreleasing *objectData = [data dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary __autoreleasing *jsonDictionary = [NSJSONSerialization JSONObjectWithData:objectData
                                                                                   options:kNilOptions
                                                                                     error:&error];
    objectData = nil;
    
    if (onParseComplete) {
        if (error) {
            onParseComplete(nil);
        } else {
            onParseComplete(jsonDictionary);
        }
        
        onParseComplete = nil;
    }
}
@end
