//
//  URLProtocolStub.swift
//  Interview
//
//  Created by Thiago Monteiro on 8/20/26.
//  Copyright © 2026 PicPay. All rights reserved.
//

import XCTest
import Interview

final class URLProtocolStub: URLProtocol {
    private struct Stub {
        let data: Data?
        let response: URLResponse?
        let error: Swift.Error?
    }

    private static var stub: Stub?
    private static var requestObserver: ((URLRequest) -> Void)?

    static func stub(data: Data?, response: URLResponse?, error: Swift.Error?) {
        stub = Stub(data: data, response: response, error: error)
    }

    static func observeRequests(observer: @escaping (URLRequest) -> Void) {
        requestObserver = observer
    }

    static func startInterceptingRequests() {
        URLProtocol.registerClass(URLProtocolStub.self)
    }

    static func stopInterceptingRequests() {
        URLProtocol.unregisterClass(URLProtocolStub.self)
        stub = nil
        requestObserver = nil
    }

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let requestObserver = URLProtocolStub.requestObserver {
            requestObserver(request)
        }

        if let data = URLProtocolStub.stub?.data {
            client?.urlProtocol(self, didLoad: data)
        }

        if let response = URLProtocolStub.stub?.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let error = URLProtocolStub.stub?.error {
            client?.urlProtocol(self, didFailWithError: error)
        } else {
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}
