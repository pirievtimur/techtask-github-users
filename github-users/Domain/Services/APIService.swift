import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

protocol GitHubUsersAPI {
    func users(perPage: UInt, since: UInt?) -> Observable<[GitHubUser]>
}

class APIService {}

extension APIService: GitHubUsersAPI {
    
    enum GitHubUsersAPIError: Error {
        case parsingError
    }
    
    private var usersURLString: String {
        return "https://api.github.com/users"
    }
    
    func users(perPage: UInt, since: UInt?) -> Observable<[GitHubUser]> {
        assert(perPage != 0, "perPage parameter cant be 0")
        guard var urlComponents = URLComponents(string: usersURLString) else { return .empty() }
        var queryItems: [URLQueryItem] = [URLQueryItem(name: "per_page", value: String(perPage))]
        if let since = since {
            queryItems.append(URLQueryItem(name: "since", value: String(since)))
        }
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else { return .empty() }
        
        return URLSession.shared.rx.json(url: url).retry(1).map {
            guard let users = Mapper<GitHubUser>().mapArray(JSONObject: $0) else {
                throw GitHubUsersAPIError.parsingError
            }
            
            return users
        }
    }
}
