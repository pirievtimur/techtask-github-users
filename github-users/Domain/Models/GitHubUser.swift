import ObjectMapper

struct GitHubUser {
    var login: String
    var userId: UInt
    var avatarURLString: String?
    var profileHtmlURLString: String?
    var followersURLString: String?
}

extension GitHubUser: UserInfoPresentable {

    var userImageURL: URL? {
        guard let urlString = avatarURLString else { return nil }
        return URL(string: urlString)
    }
    
    var username: String {
        return login
    }
    
    var profileURL: URL? {
        guard let urlString = profileHtmlURLString else { return nil }
        return URL(string: urlString)
    }
    
}

extension GitHubUser: Mappable {
    init?(map: Map) {
        login = ""
        userId = 0
    }
    
    mutating func mapping(map: Map) {
        login <- map["login"]
        userId <- map["id"]
        avatarURLString <- map["avatar_url"]
        profileHtmlURLString <- map["html_url"]
        followersURLString <- map["followers_url"]
    }
}
