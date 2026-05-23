//
//  ViewController.swift
//  RxSwiftLec1
//
//  Created by Mona Zarea on 18/05/2026.
//
import RxSwift
import RxCocoa
import Combine
import UIKit


let url = URL(string: "https://raw.githubusercontent.com/DevTides/NewsApi/master/news.json")!
var cancellables = Set<AnyCancellable>()

class ViewController: UIViewController {
    
    
    @IBOutlet weak var switchBtn: UISwitch!
    
    @IBOutlet weak var textLabel: UILabel!
    
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testPublisherOperators()
        fetchNews()
    }
    
    
    
    
    
    func fetchNews() {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: DispatchQueue.main)
            .map { $0.data }
            .decode(type: [News].self, decoder: JSONDecoder())
            .mapError({ error -> APIError in
                switch error {
                case URLError.cannotFindHost:
                    return .invalidURL
                case URLError.notConnectedToInternet:
                    return .responseError(error: error)
                default: return .unknown
                }
            })
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Finished")
                case .failure(let error):
                    print("error : \(error)")
                }
            }, receiveValue: { [weak self] news in
                guard let self = self else { return }
                
                print("subscription : \(Thread.isMainThread)")
                
                if let firstNews = news.first {
                    self.titleLabel.text = firstNews.title
                    self.authorLabel.text = firstNews.author
                }
            })
            .store(in: &cancellables)
        
    }
    
    func testPublisherOperators(){
        print("\n--- ReplaceNil , scan Operators ---")
        [1,2,3,4,5,6,7,nil].publisher
            .replaceNil(with: 0)
            .scan(0, +)
            .sink{
                print("Chanin total : \($0)")
            }.store(in: &cancellables)
        
        print("\n--- RemoveDublicates, CompactMap, filter Operators ---")
        ["10", "20", "20" ,"Mona", "30", "Swift"].publisher
            .removeDuplicates()
            .compactMap { Int($0)}
            .filter{$0 > 15}
            .sink{print("Final: \($0)")}
            .store(in: &cancellables)
        
        print("\n--- Collect(count) Operator ---")
        [1, 2, 3, 4, 5, 6, 7].publisher
            .collect(3)
            .sink { print("Collected Pack: \($0)") }
            .store(in: &cancellables)
        
        
        print("\n--- Reduce Operator ---")
        [1, 2, 3, 4].publisher
            .reduce(0) { runningTotal, currentValue in
                return runningTotal + currentValue
            }
            .sink { print("Final Reduced Total: \($0)") }
            .store(in: &cancellables)
        
        print("\n--- Count Operator ---")
        [1, 2, 3, 4, 5, 6, 7].publisher
            .count()
            .sink { print("Total number : \($0)") }
            .store(in: &cancellables)
        
        print("--- Catch Operator ---")
        Fail<String, APIError>(error: .networkFailed)
            .catch { error -> Just<String> in
                print("Catch caught an error: \(error), replacing with fallback data.")
                return Just("Offline Data / Cached Data")
            }
            .sink(receiveCompletion: { print("Completion: \($0)") },
                  receiveValue: { print("Value: \($0)") })
            .store(in: &cancellables)
        
        
        print("\n--- TryCatch Operator ---")
        Fail<String, APIError>(error: .invalidData)
            .tryCatch { error -> Just<String> in
                if case .networkFailed = error {
                    return Just("Fallback for network")
                } else {
                    throw APIError.invalidData
                }
            }
            .sink(receiveCompletion: { print("Completion: \($0)") },
                  receiveValue: { print("Value: \($0)") })
            .store(in: &cancellables)
        
        
        print("\n--- Retry Operator ---")
        let serverRequest = Fail<String, APIError>(error: .networkFailed)
        
        serverRequest
            .retry(2)
            .catch { _ in Just("Failed after retries") }
            .sink { print("Value: \($0)") }
            .store(in: &cancellables)
        
        
        print("\n--- AssertNoFailure Operator ---")
        Just("Perfect Data")
            .setFailureType(to: APIError.self)
            .assertNoFailure("This should never fail! If it does, crash the app.")
            .sink { print("Value: \($0)") }
            .store(in: &cancellables)
    }
    
    func testTimeOperators() {
        
        let searchSubject = PassthroughSubject<String, Never>()
        
        searchSubject
            .delay(for: .seconds(2), scheduler: DispatchQueue.main)
            .sink { print(" Delay (after 2 sec): \($0)") }
            .store(in: &cancellables)
        
        searchSubject
            .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
            .sink { print(" Debounce (waited for pause): \($0)") }
            .store(in: &cancellables)
        
        searchSubject
            .throttle(for: .seconds(2), scheduler: DispatchQueue.main, latest: true)
            .sink { print("Throttle (1 per 2 sec): \($0)") }
            .store(in: &cancellables)
        
        let networkSubject = PassthroughSubject<String, APIError>()
        networkSubject
            .timeout(.seconds(3), scheduler: DispatchQueue.main, customError: { .networkFailed })
            .sink(receiveCompletion: { print("Timeout Completion: \($0)") },
                  receiveValue: { print("Timeout Value: \($0)") })
            .store(in: &cancellables)
        
        
        searchSubject.send("M")
        searchSubject.send("Mo")
        searchSubject.send("Mon")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            searchSubject.send("Mona")
        }
    }
}
struct News : Decodable{
    let author : String
    let title : String
    let desription : String
    let imageUrl : String
    let url : String
    let publishedAt : String
}

enum APIError : Error{
    case invalidURL
    case responseError(error : Error)
    case unknown
    case networkFailed
    case invalidData
}

