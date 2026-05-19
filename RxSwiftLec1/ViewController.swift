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
    
   
    @IBOutlet weak var switchBtn: UISwitch!
    
    @IBOutlet weak var textLabel: UILabel!
    
    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()
        
    
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
    }
    
    

    
    
    
}

