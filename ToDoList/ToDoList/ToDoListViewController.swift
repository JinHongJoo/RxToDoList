//
//  ToDoListViewController.swift
//  ToDoList
//
//  Created by 주진홍 on 2023/01/10.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class ToDoListViewController: UIViewController {
    
    let disposeBag = DisposeBag()
    
    let toDoViewModel = ToDoListViewModel.shared
    
    private let signUpAction = UIAlertAction(title: "등록", style: .default)
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 50
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavigationBar()
        self.setupLayout()
        self.bindings()
    }
    
    func bindings() {
        toDoViewModel.toDoListCellData
            .drive(tableView.rx.items) { tv, index, item in
                let cell = UITableViewCell()
                var content = cell.defaultContentConfiguration()
                content.text = item.title
                cell.contentConfiguration = content
                
                return cell
            }
            .disposed(by: disposeBag)
        
        tableView.rx.itemMoved
            .map{($0.sourceIndex.row, $0.destinationIndex.row)}
            .bind(to: toDoViewModel.movePosition)
            .disposed(by: disposeBag)
        
        tableView.rx.itemDeleted
            .map{$0.row}
            .bind(to: toDoViewModel.deleteIndex)
            .disposed(by: disposeBag)
    }

}
private extension ToDoListViewController {
    func setupNavigationBar() {
        let addTappedAction = UIAction { [weak self] _ in
            let alertController = UIAlertController(title: "할 일 등록", message: nil, preferredStyle: .alert)
            let signUpAction = UIAlertAction(title: "등록", style: .default) { _ in
                guard let text = alertController.textFields?[0].text else { return }
                self?.toDoViewModel.newData.accept(ToDoModel(title: text))
            }
            let cencelAction = UIAlertAction(title: "취소", style: .cancel)
            alertController.addTextField {
                $0.placeholder = "할 일을 입력해주세요."
            }
            alertController.addAction(signUpAction)
            alertController.addAction(cencelAction)
            self?.present(alertController, animated: true)
        }
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editModeAction))
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: addTappedAction)
    }
    
    @objc func editModeAction() {
        if tableView.isEditing {
            tableView.setEditing(false, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Edit"
        }else {
            tableView.setEditing(true, animated: true)
            self.navigationItem.leftBarButtonItem?.title = "Done"
        }
    }
    
    func setupLayout() {
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

