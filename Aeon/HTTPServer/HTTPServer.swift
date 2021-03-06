// HTTPServer.swift
//
// The MIT License (MIT)
//
// Copyright (c) 2015 Zewo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import HTTP

public struct HTTPServer: HTTPServerType {
    public let server: TCPServerType
    public let parser: HTTPRequestParserType = HTTPParser()
    public let responder: HTTPContextResponderType
    public let serializer: HTTPResponseSerializerType = HTTPSerializer()

    struct HTTPResponder: HTTPContextResponderType {
        let respond: HTTPRequest throws -> HTTPResponse
        func respond(context: HTTPContext) {
            let response: HTTPResponse
            do {
                response = try respond(context.request)
            } catch {
                response = HTTPResponse(status: .InternalServerError)
            }
            context.respond(response)
        }
    }

    public init(port: Int, responder: HTTPContextResponderType) {
        self.server = TCPServer(port: port)
        self.responder = responder
    }

    public init(port: Int, responder: HTTPResponderType) {
        self.server = TCPServer(port: port)
        self.responder = HTTPResponder(respond: responder.respond)
    }

    public init(port: Int, respond: HTTPRequest throws -> HTTPResponse) {
        self.server = TCPServer(port: port)
        self.responder = HTTPResponder(respond: respond)
    }

    public init(port: Int, respond: HTTPRequest -> HTTPResponse) {
        self.server = TCPServer(port: port)
        self.responder = HTTPResponder(respond: respond)
    }
}
