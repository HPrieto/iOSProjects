
import Foundation
import TRON
import SwiftyJSON

struct Service {

    let tron = TRON(baseURL: "https://api.letsbuildthatapp.com")

    static let sharedInstance = Service()

    func fetchHomeFeed(completion: @escaping (HomeDatasource?, Error?) -> ()) {

        let request: APIRequest<HomeDatasource, JSONError> = tron.request("/twitter/home")

        request.perform(withSuccess: { (homeDatasource) in
            completion(homeDatasource, nil)
        }) { (err) in

            completion(nil, err)
        }
    }

    class JSONError: JSONDecodable {
        required init(json: JSON) throws {
            print("JSON ERROR")
        }
    }

}
