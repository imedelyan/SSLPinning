import Alamofire
import Moya

final class NetworkClient {
  
  private lazy var serverTrustPolicies: [String: ServerTrustPolicy] = [
    "api.stackexchange.com": .pinCertificates(certificates: [Certificates.stackExchange], validateCertificateChain: true, validateHost: true),
//    "api.stackexchange.com": .pinPublicKeys(publicKeys: stackExchangePublicKeys, validateCertificateChain: true, validateHost: true)
  ]
  
  private var stackExchangePublicKeys: [SecKey] {
    var trust: SecTrust?
    let policy = SecPolicyCreateBasicX509()
    let status = SecTrustCreateWithCertificates(Certificates.stackExchange, policy, &trust)

    guard let secTrust = trust else { return [] }
    var key: SecKey?
    if status == errSecSuccess {
      key = SecTrustCopyPublicKey(secTrust)
    }
    guard let secKey = key else { return [] }
    return [secKey]
  }
  
  private lazy var manager = Manager(
    configuration: .default,
    serverTrustPolicyManager: ServerTrustPolicyManager(policies: serverTrustPolicies)
  )
  
  private lazy var provider = MoyaProvider<StackExchangeAPI>(
    manager: manager,
    plugins: [NetworkLoggerPlugin(verbose: true)]
  )
  
  func fetshUsers(completion: @escaping (Swift.Result<[User], NetworkError>) -> Void) {
    provider.request(.users) { result in
      switch result {
      case let .success(response):
        do {
          let userList = try JSONDecoder().decode(UserList.self, from: response.data)
          completion(.success(userList.users))
        } catch {
          completion(.failure(.decodingError))
        }
      case .failure:
        completion(.failure(.sslPinningError))
      }
    }
  }
}

enum NetworkError: Error {
  case decodingError
  case sslPinningError
}

struct Certificates {
  static let stackExchange = Certificates.certificate(filename: "stackexchange.com", type: "der")
  
  private static func certificate(filename: String, type: String) -> SecCertificate {
    let filePath = Bundle.main.path(forResource: filename, ofType: type)!
    let data = try! Data(contentsOf: URL(fileURLWithPath: filePath))
    let certificate = SecCertificateCreateWithData(nil, data as CFData)!
    return certificate
  }
}
