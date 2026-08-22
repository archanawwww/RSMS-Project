import Foundation

class MockDataService {
    static let shared = MockDataService()
    
    private init() {}
    
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
    
    func load<T: Decodable>(_ filename: String, as type: T.Type = T.self) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            fatalError("Could not find \(filename).json in bundle.")
        }
        
        let data = try Data(contentsOf: url)
        return try decoder.decode(T.self, from: data)
    }
}
