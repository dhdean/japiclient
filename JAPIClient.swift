//
//  JAPIClient.swift
//
//  Created by Daniel Dean on 12/18/16.
//

import Foundation

//public typealias HTErrorCallback = (NSError?) -> Void
public typealias JAPICallback = (Dictionary<String,AnyObject>?, NSError?) -> Void


/**
 ///////////////////////////////////////////////////////////////////////////////
 JSON API Request Configuration.
 ///////////////////////////////////////////////////////////////////////////////
 */
open class JAPIReq: HTReq {
    open var api:String? = ""
    open var action:String? = ""
    open var version:String? = ""
    open var query:Dictionary = [String: String]()
}


/**
 ///////////////////////////////////////////////////////////////////////////////
 JSON API Client.
 ///////////////////////////////////////////////////////////////////////////////
 */
open class JAPIClient: HTClient {
 
    /**
     Begins an HTTP request expecting a JSON response.
     
     - param apiReq: The API request configuration object
     - param handler: The completion handler fired when the request completes.
     
     - returns: The data task representation of the request.
     */
    @discardableResult
    open func dispatch(_ apiReq: JAPIReq, handler:@escaping JAPICallback) -> URLSessionDataTask {
        return super.dispatch(self.resolveHTReq(apiReq)) { (data: Data?, status: Int, error: NSError?) in
            // Look for transport/socket/timeout error
            if (error != nil) {
                handler(nil, error)
                return
            }
            // Use http status to determine whether to attempt parsing response.
            let statusErr = self.evaluateStatusCode(status, responseData: data!)
            if statusErr != nil {
                handler(nil, statusErr)
                return
            }
            do {
                // Expect JSON object
                let jsonDict:Dictionary<String,AnyObject>? = try data!.jsonDataAsDictionary()
                handler(jsonDict, nil)
            } catch let jsonErr as NSError  {
                handler(nil, NSError(domain:jsonErr.domain, code:jsonErr.code, userInfo:["response": data ?? Data()]))
                return;
            }
        }
    }
    
    /**
     Override this method in your JAPIClient subclass if you want to customize
     the response handling for HTTP status codes.  For example, if you want to
     ignore 400 as an error, or if you want to customize the content returned
     in the error object, you can do that in your override of this method.
     
     - param code: The status code of the HTTP response
     - param responseData: The body of the HTTP response
     
     - returns: Error object or nil
     */
    open func evaluateStatusCode(_ code: Int, responseData: Data?) -> NSError? {
        if (code != 200) {
            return NSError(domain: "net.dhdean.japiclent", code: code, userInfo: ["response": responseData ?? Data()])
        }
        return nil
    }

    /**
     The default behavior of the JAPI is that it assumes you send a dictionary
     of key/value pairs which will map to url parameters or post body 
     parameters.  Override this method in your JAPIClient subclass if you want 
     to use an alternative to either the convenience dictionary or data body.
     For example, if you need to customize the body of a request depending on
     its target url, that can be done in your override of this function.
     
     - param apiReq: the request configuration
     
     - returns: The body data for the request
     */
    open func resolveBody(_ apiReq: JAPIReq) -> Data? {
        if apiReq.body != nil {
            return apiReq.body as Data?
        }
        
        if apiReq.query.count > 0 {
            let data = apiReq.query.stringifyAsURLParams(true).data(using: String.Encoding.utf8)!
            return data
        }
        
        return nil
    }
    
    /**
     Override this method in your JAPIClient subclass to construct the final url
     from the request api and action properties.
     
     - param apiReq: the request configuration
     
     - returns: The constructed url for the request
     */
    open func resolveUrl(_ apiReq: JAPIReq) -> String? {
        return apiReq.url
    }
    
    /**
     Constructs an HTReq object from a given JAPIReq object
     
     - param apiReq: the request configuration
     
     - returns: The HTTP request configuration
     */
    private func resolveHTReq(_ apiReq: JAPIReq) -> HTReq {
        let req = HTReq()
        req.method = apiReq.method
        req.headers = apiReq.headers
        req.url = self.resolveUrl(apiReq)
        req.body = self.resolveBody(apiReq)
        req.cellular = apiReq.cellular
        req.timeout = apiReq.timeout
        return req
    }
    
}
