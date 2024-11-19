import Foundation
import Combine



class SSEManager: NSObject, URLSessionDelegate {
    private var request: URLRequest
    private var session: URLSession?
    private var dataTask: URLSessionDataTask?
    private var dataReceived: ((String) -> Void)?

    init(request: URLRequest) {
        self.request = request
        super.init()
        self.session = URLSession(configuration: .default, delegate: self, delegateQueue: .main)
    }

    func startRequest() {
        self.dataTask = session?.dataTask(with: request)
        self.dataTask?.resume()
    }

    func stopRequest() {
        self.dataTask?.cancel()
        self.session?.invalidateAndCancel()
    }

    func setDataReceivedCallback(_ callback: @escaping (String) -> Void) {
        self.dataReceived = callback
    }
}

extension SSEManager: URLSessionDataDelegate {
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        if let dataStr = String(data: data, encoding: .utf8) {
            print("🌞 ： data ------------>  \(dataStr)")
            let objDataStrArray = dataStr.components(separatedBy: "data: ")
            objDataStrArray.forEach { dataStr in
                if !dataStr.isEmpty {
                    self.dataReceived?(dataStr)
                }
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        // Handle request completion or error
        if let error = error {
            print("SSE request completed with error: \(error.localizedDescription)")
        } else {
            print("SSE request completed successfully")
        }
    }
}
