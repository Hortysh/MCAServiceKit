import Foundation

public class APIService {
    
    @MainActor public static let shared = APIService()
    
    private init() {
        
    }
    
    public func start() {
        print("IT STARTED MAN!")
    }
}
