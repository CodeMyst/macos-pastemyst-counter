import SwiftUI

extension Formatter {
    static let withSeparator: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        return formatter
    }()
}

extension Numeric {
    var formattedWithSeparator: String { Formatter.withSeparator.string(for: self) ?? "" }
}

struct ResponseDto: Decodable {
    var numPastes: Int
}

@main
struct macos_pastemyst_counterApp: App {
    @State var pasteCount = 0

    var body: some Scene {
        MenuBarExtra {
            Button ("quit") {
                NSApplication.shared.terminate(nil)
            }
        } label: {
            Text("pm: " + pasteCount.formattedWithSeparator).onAppear(perform: {
                fetchCount()
                
                Timer.scheduledTimer(withTimeInterval: 5 * 60.0, repeats: true) {
                    time in
                        fetchCount()
                }
            })
        }
    }

    func fetchCount() {
        var request = URLRequest(url: URL(string: "https://paste.myst.rs/api/v2/data/numPastes")!)
        request.httpMethod = "GET"

        URLSession.shared.dataTask(with: request, completionHandler: { data, response, error -> Void in
            do {
                let jsonDecoder = JSONDecoder()
                let responseModel = try jsonDecoder.decode(ResponseDto.self, from: data!)
                pasteCount = responseModel.numPastes
            } catch {
                print("failed to fetch paste count")
            }
        }).resume()
    }
}
