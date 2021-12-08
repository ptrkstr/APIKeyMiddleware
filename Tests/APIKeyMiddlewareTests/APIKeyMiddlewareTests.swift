import XCTest
import XCTVapor
@testable import APIKeyMiddleware

private class Delegate_Mock: APIKeyMiddlewareDelegate {
    var mock_errorForMissingKey: ((_ middleware: APIKeyMiddleware) -> Error?)?
    var mock_errorForUnauthorizedKey: ((_ middleware: APIKeyMiddleware) -> Error?)?
    
    init() {}
    
    func errorForMissingKey(in middleware: APIKeyMiddleware) -> Error? {
        mock_errorForMissingKey?(middleware)
    }
    
    func errorForUnauthorizedKey(in middleware: APIKeyMiddleware) -> Error? {
        mock_errorForUnauthorizedKey?(middleware)
    }
}

final class APIKeyMiddlewareTests: XCTestCase {
    
    func test_success() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let middleware = APIKeyMiddleware()
        app.grouped(middleware).get("") { _ in "" }
        var headers = HTTPHeaders()
        
        // GIVEN api key middleware contains a required key
        middleware.keys = ["123"]
        
        // WHEN a request is fired with the required key
        headers.apiKey = "123"
        try app.testable().test(.GET, "", headers: headers) { res in
            
            // THEN a successful response is received
            XCTAssertEqual(res.status, .ok)
        }
    }
    
    func test_badrequest() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let middleware = APIKeyMiddleware()
        app.grouped(middleware).get("") { _ in "" }
        
        // GIVEN api key middleware contains a required key
        middleware.keys = ["123"]
        
        // WHEN a request is fired with no key
        try app.testable().test(.GET, "") { res in
            
            // THEN a missing key error is seen
            XCTAssertEqual(res.status, .badRequest)
            XCTAssertEqual(res.body.string, "{\"error\":true,\"reason\":\"Missing api-key.\"}")
        }
    }
    
    func test_unauthorized() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let middleware = APIKeyMiddleware()
        app.grouped(middleware).get("") { _ in "" }
        var headers = HTTPHeaders()
        
        // GIVEN api key middleware contains a required key
        middleware.keys = ["123"]
        
        // WHEN a request is fired without the correct key
        headers.apiKey = "1234"
        try app.testable().test(.GET, "", headers: headers) { res in
            
            // THEN an unauthorized error is seen
            XCTAssertEqual(res.status, .unauthorized)
            XCTAssertEqual(res.body.string, "{\"error\":true,\"reason\":\"Unauthorized api-key.\"}")
        }
    }
    
    func test_badrequest_delegate() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let delegate = Delegate_Mock()
        let middleware = APIKeyMiddleware(keys: ["123"], delegate: delegate)
        app.grouped(middleware).get("") { _ in "" }
        
        // GIVEN delegate throws an error for missing key
        delegate.mock_errorForMissingKey = { _ in
            Abort(.expectationFailed, reason: "Missing api-key, please check header.")
        }
        
        // WHEN a request is sent with missing key
        try app.testable().test(.GET, "") { res in
            
            // THEN error given by delegate is thrown
            XCTAssertEqual(res.status, .expectationFailed)
            XCTAssertEqual(res.body.string, "{\"error\":true,\"reason\":\"Missing api-key, please check header.\"}")
        }
    }
    
    func test_unauthorized_delegate() throws {
        let app = Application(.testing)
        defer { app.shutdown() }
        let delegate = Delegate_Mock()
        let middleware = APIKeyMiddleware(keys: ["123"], delegate: delegate)
        app.grouped(middleware).get("") { _ in "" }
        var headers = HTTPHeaders()
        
        // GIVEN delegate throws an error for unauthorized key
        delegate.mock_errorForUnauthorizedKey = { _ in
            Abort(.forbidden, reason: "Unauthorized api-key, please check header.")
        }
        
        // WHEN a request is sent with missing key
        headers.apiKey = "1234"
        try app.testable().test(.GET, "", headers: headers) { res in
            
            // THEN error given by delegate is thrown
            XCTAssertEqual(res.status, .forbidden)
            XCTAssertEqual(res.body.string, "{\"error\":true,\"reason\":\"Unauthorized api-key, please check header.\"}")
        }
    }
    
    func test_removingAPIKey() throws {
        var headers = HTTPHeaders()
        
        // GIVEN api key is added to headers
        headers.apiKey = "123"
        
        // WHEN api key is removed from headers
        headers.apiKey = nil
        
        // THEN it no longer exists in headers
        XCTAssertNil(headers.apiKey)
    }
}
