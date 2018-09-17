import RxCocoa
import RxSwift
import ObjectMapper

protocol GitHubUserFollowersAPI {
    func followers(urlString: String, page: UInt, perPage: UInt) -> Observable<[GitHubUser]>
}

extension APIService: GitHubUserFollowersAPI {
    func followers(urlString: String, page: UInt, perPage: UInt) -> Observable<[GitHubUser]> {
        assert(perPage != 0, "perPage parameter cant be 0")
        assert(page != 0, "page parameter cant be 0")
        guard var urlComponents = URLComponents(string: urlString) else { return .empty() }
        urlComponents.queryItems = [URLQueryItem(name: "per_page", value: String(perPage)),
                                    URLQueryItem(name: "page", value: String(page))]
        
        guard let url = urlComponents.url else { return .empty() }
        
        return URLSession.shared.rx.json(url: url).map {
            guard let users = Mapper<GitHubUser>().mapArray(JSONObject: $0) else {
                throw APIServiceErrors.parsingError
            }
            
            return users
        }
    }
}
