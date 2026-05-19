//
//  ViewController.swift
//  RxSwiftLec1
//
//  Created by Mona Zarea on 18/05/2026.
//
import RxSwift
import RxCocoa
import UIKit

class ViewController: UIViewController {
    

    @IBOutlet weak var DebounceThrottleLable: UILabel!
    @IBOutlet weak var throttleBTN: UIButton!
    @IBOutlet weak var debounceBTN: UIButton!
    @IBOutlet weak var arrayLabel: UILabel!
    @IBOutlet weak var switchBtn: UISwitch!
    
    @IBOutlet weak var textLabel: UILabel!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        arrayLabel.numberOfLines = 0
        arrayLabel.lineBreakMode = .byWordWrapping
    
        testDebounce()
        testThrottle()
        writeArrayDetails()
        practiceOperators()
        
        
        switchBtn.rx.isOn
            .map{ isOn in
                return isOn ? "On" : "OFF"
            }.bind(to:textLabel.rx.text).disposed(by: disposeBag)
        
//        switchBtn.rx.isOn
//            .map{ isOn in
//                return isOn ? "On" : "OFF"
//            }.subscribe{
//                [weak self] result in
//                guard let self = self else{return}
//                self.textLabel.text = result
//            }onCompleted: {
//                print("Completed")
//            }.disposed(by: disposeBag)
   
        
        let names = ["mona","esraa"]
        let observable1 : Observable<[String]> = Observable<[String]>.just(names)
        
        let observable2 : Observable<[String]> = Observable<[String]>.of(names,names)
        let observable3 : Observable<String> = Observable<String>.from(names)

        let observable4 : Observable<String> = Observable<String>.create{ observer in          observer.onNext("sahar")
            observer.onNext("abeer")
            DispatchQueue.main.asyncAfter(deadline: .now()+2, execute: {
                observer.onNext("amal")
                observer.onCompleted()
            })
            
            observer.onNext("menna")
            return Disposables.create()
        }
        
        observable4.subscribe(onNext: { value in
            print(value)
        },onCompleted: {
          print("Completed")
        },onDisposed: {
            print("disposed..")
        })
        
        
        
        
        // using global
        
        DispatchQueue.global(qos: .userInitiated).async {[weak self] in
            guard let self = self else {return}
            let arr = self.getLargeArray()
            let sum = arr.reduce(0, + )
            let firstElement = arr.first ?? 0.0
            let arrayCount = arr.count
            
            let finalResult = "sum :\(sum), firstElement: \(firstElement), arrayCount: \(arrayCount)"
            
            DispatchQueue.main.async{
                self.arrayLabel.text = finalResult
            }
        }
        
        
        
    }
    
    func writeArrayDetails(){
        let mainSchedular = MainScheduler.instance
        let bgSchedular = ConcurrentDispatchQueueScheduler(qos: .background)
        
        let observable = Observable<String>.create{[weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }
            let arr = self.getLargeArray()
            let sum = arr.reduce(0, + )
            let firstElement = arr.first ?? 0.0
            let arrayCount = arr.count
            let finalResult = "sum :\(sum), firstElement: \(firstElement), arrayCount: \(arrayCount)"
            
            observer.onNext(finalResult)
            return Disposables.create()
        }
        
        observable
            .subscribeOn( bgSchedular)
            .observeOn(mainSchedular)
            .subscribe(onNext : {[weak self] resutl in
                self?.arrayLabel.text = resutl
                
            }).disposed(by: disposeBag)
        
    }
    
    
    func testDebounce(){
        var counter = 0
        debounceBTN.rx.tap.debounce(.seconds(1), scheduler: MainScheduler.instance).subscribe{[weak self] value in
            guard let self = self else {return}
            counter  = counter + 1
            self.DebounceThrottleLable.text = "\(counter)"
            
        }.disposed(by: disposeBag)
    }
    
    func testThrottle(){
        var counter = 0
        throttleBTN.rx.tap.throttle(.seconds(10), scheduler: MainScheduler.instance).subscribe{[weak self] value in
            guard let self = self else {return}
            counter  = counter + 1
            self.DebounceThrottleLable.text = "\(counter)"
            
        }.disposed(by: disposeBag)
    }
    
    func practiceOperators(){
        let observable = Observable.of(1, 2, 3, 4, 5, 6, 7, 8,9,10).map{$0 * 5}.filter{$0 % 2 == 0}.skip(2).take(10).subscribe(onNext: {value in
            print(value)
        })
        
    }
    func getLargeArray() ->[Double]{
        var array : [Double] = []
        for i in 0...1000000{
            array.append(Double(i))
        }
        return array
    }

    
    
}

