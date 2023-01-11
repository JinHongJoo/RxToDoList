//
//  ToDoListViewModel.swift
//  ToDoList
//
//  Created by 주진홍 on 2023/01/10.
//

import Foundation
import RxSwift
import RxCocoa

struct ToDoListViewModel {
    static let shared = ToDoListViewModel()
    
    let disposeBag = DisposeBag()
    
    let newData = PublishRelay<ToDoModel>()
    let movePosition = PublishRelay<(Int, Int)>()
    let deleteIndex = PublishRelay<Int>()
    
    let toDoData = BehaviorRelay<[ToDoModel]>(value: [])
    let toDoListCellData: Driver<[ToDoModel]>
    
    init() {
        toDoListCellData = toDoData
            .asDriver(onErrorDriveWith: .empty())
        
        getTodoList()
            .bind(to: toDoData)
            .disposed(by: disposeBag)
        
        newData
            .withLatestFrom(toDoData){ $1 + [$0]}
            .do {
                UserDefaults.standard.set(try? PropertyListEncoder().encode($0), forKey: "todoList")
            }
            .bind(to: toDoData)
            .disposed(by: disposeBag)
        
        movePosition
            .withLatestFrom(toDoData) { (movePath, data) -> [ToDoModel] in
                var datas = data
                datas.remove(at: movePath.0)
                datas.insert(data[movePath.0], at: movePath.1)
                
                return datas
            }
            .do {
                UserDefaults.standard.set(try? PropertyListEncoder().encode($0), forKey: "todoList")
            }
            .bind(to: toDoData)
            .disposed(by: disposeBag)
        
        deleteIndex
            .withLatestFrom(toDoData) { (index, data) -> [ToDoModel] in
                var datas = data
                datas.remove(at: index)
                
                return datas
            }
            .do {
                UserDefaults.standard.set(try? PropertyListEncoder().encode($0), forKey: "todoList")
            }
            .bind(to: toDoData)
            .disposed(by: disposeBag)
                
    }
    
    private func getTodoList() -> Observable<[ToDoModel]> {
        return Observable<[ToDoModel]>.create { observer in
            if let data = UserDefaults.standard.value(forKey:"todoList") as? Data {
                let list = try? PropertyListDecoder().decode([ToDoModel].self, from: data)
                
                if let list = list {
                    observer.onNext(list)
                }
            }
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
}
