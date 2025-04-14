import Foundation

public enum APIError: LocalizedError {
    case badRequest(description: String)
    case decodingError(description: String)
    case networkFailure(URLError)
    case serverError(statusCode: Int, description: String?, responseData: Data?)
    case invalidResponse
    case unknown(Error)
    
    public var errorDescription: String? {
        switch self {
        case .badRequest(let description):
            return "Неверный запрос: \(description)"
        case .decodingError(let description):
            return "Ошибка декодирования: \(description)"
        case .networkFailure(let urlError):
            return "Ошибка сети: \(urlError.localizedDescription)"
        case .serverError(let statusCode, let description, let responseData):
            var errorText = "Ошибка сервера. Код: \(statusCode), описание: \(description ?? "Нет описания")"
            if let data = responseData, let jsonString = String(data: data, encoding: .utf8) {
                errorText += "\nОтвет: \(jsonString)"
            }
            return errorText
        case .invalidResponse:
            return "Получен неверный ответ от сервера (не HTTP)"
        case .unknown(let error):
            return "Неизвестная ошибка: \(error.localizedDescription)"
        }
    }
}
