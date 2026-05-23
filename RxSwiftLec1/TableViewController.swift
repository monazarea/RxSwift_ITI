//
//  TableViewController.swift
//  RxSwiftLec1
//
//  Created by Mona Zarea on 20/05/2026.
//

import UIKit
import RxSwift

struct Person{
    let firstName : String
    let lastName : String
    
    init(fullName: String){
        let parts = fullName.split(separator: " ")
        self.firstName = String(parts.first ?? "")
        self.lastName = parts.count > 1 ? parts.dropFirst().joined(separator: " ") : ""
    }
    
    var displayString : String {
        return self.lastName.isEmpty ? firstName : "\(firstName) \(lastName)"
    }
}


class TableViewController: UIViewController {

    @IBOutlet weak var mytableview: UITableView!
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setupTableUsingNormalWay()
       // setupTableUsingNormalWay2()
        //setupTableUsingNormalWayUsingGlobal()
        setupTableViewWithPublishSubject()
    }
    

    func setupTableUsingNormalWay(){
        let initialData = ["beshoy", "Mona Ahmed", "Ahmed Essam"].map { Person(fullName: $0) }
        let expandedData = initialData + [Person(fullName: "Ali Gamal")]
        
        let observable1 = Observable<[Person]>.create{ observar in
            observar.onNext(initialData)
            observar.onCompleted()
            return Disposables.create()
        }
        let observable2 = Observable.just(expandedData).delay(.seconds(2), scheduler: MainScheduler.instance)
        
        let combinedObservable = Observable.concat([observable1, observable2])
        combinedObservable.bind(to: mytableview.rx.items(cellIdentifier: "Cell", cellType: NameTableViewCell.self)){ index , Person , cell in
            cell.textLabel?.text = Person.displayString
        }.disposed(by: disposeBag)
    }
    
    func setupTableUsingNormalWay2(){
        let initialData = ["beshoy", "Mona Ahmed", "Ahmed Essam"].map { Person(fullName: $0) }
        let expandedData = initialData + [Person(fullName: "Ali Gamal")]
        
        let observable = Observable<[Person]>.create{ observar in
            observar.onNext(initialData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                observar.onNext(expandedData)
                observar.onCompleted()

            })
            return Disposables.create()
        }
        
        
        observable.bind(to: mytableview.rx.items(cellIdentifier: "Cell", cellType: NameTableViewCell.self)){ index , Person , cell in
            cell.textLabel?.text = Person.displayString
        }.disposed(by: disposeBag)
    }
    
    
    func setupTableUsingNormalWayUsingGlobal(){
        let initialData = ["beshoy", "Mona Ahmed", "Ahmed Essam"].map { Person(fullName: $0) }
        let expandedData = initialData + [Person(fullName: "Ali Gamal")]
        
        let bgSchdular = ConcurrentDispatchQueueScheduler(qos: .background)
        let observable = Observable<[Person]>.create{ observar in
            observar.onNext(initialData)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                observar.onNext(expandedData)
                observar.onCompleted()

            })
            return Disposables.create()
        }
        observable.subscribeOn(bgSchdular)
            .asDriver(onErrorJustReturn: [])
            .drive(mytableview.rx.items(cellIdentifier: "Cell", cellType: NameTableViewCell.self)){
                index, person, cell in
                cell.textLabel?.text = person.displayString
            }.disposed(by: disposeBag)
        
    }
    
    var currentData: [Person] = []
    let dataSubject = PublishSubject<[Person]>()

    func setupTableViewWithPublishSubject() {
        mytableview.isEditing = true
        
        dataSubject
            .bind(to: mytableview.rx.items(cellIdentifier: "Cell")) { index, person, cell in
                cell.textLabel?.text = person.displayString
            }
            .disposed(by: disposeBag)
        
        currentData = ["beshoy", "Mona Ahmed", "Ahmed Essam"].map { Person(fullName: $0) }
        dataSubject.onNext(currentData)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.currentData.append(Person(fullName: "Ali Gamal"))
            self.dataSubject.onNext(self.currentData)
        }
        
        mytableview.rx.itemDeleted
            .subscribe(onNext: { [weak self] indexPath in
                guard let self = self else { return }
                
                self.currentData.remove(at: indexPath.row)
                
                self.dataSubject.onNext(self.currentData)
            })
            .disposed(by: disposeBag)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
