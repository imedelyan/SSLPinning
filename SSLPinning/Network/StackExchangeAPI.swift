import Moya

enum StackExchangeAPI {
    case users
}

extension StackExchangeAPI: TargetType {
  var baseURL: URL {
    return URL(string: "https://api.stackexchange.com/2.2")!
  }
  
  var path: String {
    return "/users"
  }
  
  var sampleData: Data {
    return Data()
  }
  
  var method: Moya.Method {
    return .get
  }
  
  var task: Task {
    return .requestParameters(parameters: ["order": "desc",
                                           "sort": "reputation",
                                           "site": "stackoverflow"],
                              encoding: URLEncoding.default)
  }
  
  var headers: [String: String]? {
    return nil
  }
  
  var validationType: ValidationType {
    return .successCodes
  }
}
