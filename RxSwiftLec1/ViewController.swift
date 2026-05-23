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
        setupPublisher()
        executeVariableWithDelay()
    }
    
    
    
    func setupPublisher() {
            let publisher = Just("Hello MAD 46.")
            
            publisher
                .subscribe(on: DispatchQueue.global(qos: .background))
                
                .receive(on: DispatchQueue.main)
                
                .sink { [weak self] outputText in
                    self?.titleLabel.text = outputText
                    
                    print("Is Main Thread? \(Thread.isMainThread)")
                }
                .store(in: &cancellables)
        }
    
    func executeVariableWithDelay() {
            
            [1, 2, 3, 4, 5].publisher
            
                .flatMap(maxPublishers: .max(1)) { number -> AnyPublisher<Int, Never> in
                    
                    let waitTime = Double(number - 1)
                    
                    return Just(number)
                        .delay(for: .seconds(waitTime), scheduler: DispatchQueue.main)
                        .eraseToAnyPublisher()
                }
                .sink { [weak self] value in
                    self?.authorLabel.text = "\(value)"
                    
                    print("Displayed: \(value)")
                }
                .store(in: &cancellables)
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

