<div align="center">
  <img src="Assets/logo/apikeymiddleware-logo.svg" height=150pt/>
  <h1>
    APIKeyMiddleware
  </h1>
  <div>
      <p>
          <a href="https://swiftpackageindex.com/ptrkstr/APIKeyMiddleware"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptrkstr%2FAPIKeyMiddleware%2Fbadge%3Ftype%3Dplatforms"/></a>
          <a href="https://swiftpackageindex.com/ptrkstr/APIKeyMiddleware"><img src="https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptrkstr%2FAPIKeyMiddleware%2Fbadge%3Ftype%3Dswift-versions"/></a>
      </p>
      <p>
          <a href="https://github.com/ptrkstr/APIKeyMiddleware/actions/workflows/Code Coverage.yml"><img src="https://github.com/ptrkstr/APIKeyMiddleware/actions/workflows/Code Coverage.yml/badge.svg"/></a>
          <a href="https://codecov.io/gh/ptrkstr/APIKeyMiddleware"><img src="https://codecov.io/gh/ptrkstr/APIKeyMiddleware/branch/develop/graph/badge.svg?token=GNSQ1JNEZH"/></a>          
      </p>
      <p>
          <a href="https://typescriptlang.org"><img src="https://img.shields.io/badge/Vapor Version-4-blue.svg" alt="Minimum Supported Vapor Version is 4"/></a>
          <a href="https://hits.seeyoufarm.com"><img src="https://hits.seeyoufarm.com/api/count/incr/badge.svg?url=https%3A%2F%2Fgithub.com%2Fptrkstr%2FAPIKeyMiddleware&count_bg=%2379C83D&title_bg=%23555555&icon=&icon_color=%23E7E7E7&title=hits&edge_flat=false"/></a>
      </p>
  </div>
  <p>
    Swift package for adding API Key requirement to vapor backends.
  </p>
</div>


## Features

- 😯 Supports an array of keys
- ❗️ Supports overriding thrown errors
- 💯 100% Test Coverage

## Usage

Requests are expected to have the header `api-key`.

### Simple

```swift
public func configure(_ app: Application) throws {
    app.middleware.use(APIKeyMiddleware(keys: ["123"]))
}
```

See [Vapor Docs](https://docs.vapor.codes/4.0/middleware/#configuration) if wanting to add to individual routes.

### Override Errors

The following errors are used by default:  
- Missing API key: `Abort(.badRequest, reason: "Missing api-key.")`
- Unauthorized API Key: `Abort(.unauthorized, reason: "Unauthorized api-key.")`

To override these errors, assign a delegate to the APIKeyMiddleware. Returning nil uses defaults.

```swift
class Delegate: APIKeyMiddlewareDelegate {

    static let shared = Delegate()

    init() {}

    func errorForMissingKey(in middleware: APIKeyMiddleware) -> Error? {
        Abort(.imATeapot, reason: "Missing api-key was found by teapot.")
    }

    func errorForUnauthorizedKey(in middleware: APIKeyMiddleware) -> Error? {
        Abort(.imATeapot, reason: "Unauthorized api-key was found by teapot.")
    }
}

public func configure(_ app: Application) throws {
    let middleware = APIKeyMiddleware(keys: ["123"], delegate: Delegate.shared)
    app.middleware.use(middleware)
}
```

## Installation

### SPM

Add the following to your project:

```
https://github.com/ptrkstr/APIKeyMiddleware
```

## Possible Future Features
> Raise an issue if you need these

- Allow overriding API-Key header name

