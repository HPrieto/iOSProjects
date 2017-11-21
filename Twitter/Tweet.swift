
import Foundation
import SwiftyJSON
import TRON

struct Tweet: JSONDecodable {
    let user: User
    let message: String

    init(json: JSON) {
        let userJson = json["user"]
        self.user = User(json: userJson)

        self.message = json["message"].stringValue
    }
}
