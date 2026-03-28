import Foundation
import EchoAPI

internal enum ParsedApiError {
    case message(String)
    case network(Error)
}

internal extension Error {
    func parseEchoApiError(unauthorizedMessage: String) -> ParsedApiError {
        if let apiError = self as? ErrorResponse {
            switch apiError {
            case .error(let statusCode, let data, _, let underlyingError):
                if statusCode == 401 {
                    return .message(unauthorizedMessage)
                }
                if let data = data, let stringData = String(data: data, encoding: .utf8) {
                    return .message("HTTP [\(statusCode)]: \(stringData)")
                }
                return .network(underlyingError)
            }
        }
        return .network(self)
    }
}
