import Vapor

public protocol APIKeyMiddlewareDelegate: AnyObject {
    func errorForMissingKey(in middleware: APIKeyMiddleware) -> Error?
    func errorForUnauthorizedKey(in middleware: APIKeyMiddleware) -> Error?
}

public final class APIKeyMiddleware: Middleware {
    
    public var keys: [APIKey]
    
    public weak var delegate: APIKeyMiddlewareDelegate?
    
    public init(keys: [APIKey] = [], delegate: APIKeyMiddlewareDelegate? = nil) {
        self.keys = keys
        self.delegate = delegate
    }
    
    public func respond(to request: Request, chainingTo next: Responder) -> EventLoopFuture<Response> {
        
        guard let apiKey = request.headers.apiKey else {
            let error = delegate?.errorForMissingKey(in: self) ?? Abort(.badRequest, reason: "Missing api-key.")
            return request.eventLoop.makeFailedFuture(error)
        }
        
        guard keys.contains(apiKey) else {
            let error = delegate?.errorForUnauthorizedKey(in: self) ?? Abort(.unauthorized, reason: "Unauthorized api-key.")
            return request.eventLoop.makeFailedFuture(error)
        }
        
        return next.respond(to: request)
    }
}
