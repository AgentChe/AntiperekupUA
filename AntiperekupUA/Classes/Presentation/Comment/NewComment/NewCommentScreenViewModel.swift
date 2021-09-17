//
//  NewCommentScreenViewModel.swift
//  AntiperekupUA
//
//  Created by Vitaliy Zagorodnov on 12.09.2021.
//

import RxSwift
import RxCocoa

final class NewCommentScreenViewModel {
    private lazy var commentManager = CommentManagerCore()
    
    let vin: String
    let regNumber: String
    
    init(vin: String, regNumber: String) {
        self.vin = vin
        self.regNumber = regNumber
    }
}

extension NewCommentScreenViewModel {
    struct Input {
        let selectedTheme: Signal<NewCommentTheme>
        let title: Observable<String?>
        let comment: Observable<String?>
        let didTapSend: Signal<Void>
    }
    
    struct Output {
        let dataSource: Driver<[NewCommentCellType]>
        let isSendEnabled: Driver<Bool>
        let isLoading: Driver<Bool>
        let commentAdded: Signal<Void>
        let showError: Signal<String>
    }
    
    func configure(input: Input) -> Output {
        
        let selectedTheme = input.selectedTheme
            .asObservable()
            .startWith(.mileage)
            .share(replay: 1)
        
        let currentTitle = Observable
            .combineLatest(
                selectedTheme,
                input.title.map { $0 ?? "" }
            ) { $0 != .other ? $0.name : $1 }
            .distinctUntilChanged()
            .share(replay: 1)
        
        let currentComment = input.comment
            .map { $0 ?? "" }
            .distinctUntilChanged()
        
        let currentCommentData = Observable.combineLatest(currentTitle, currentComment)
            .share(replay: 1)
        
        let isSendEnabled = currentCommentData
            .map { !$0.isEmpty && !$1.isEmpty }
            .asDriver(onErrorJustReturn: false)
        
        let dataSource = makeDataSource(currentTheme: selectedTheme)
            .asDriver(onErrorJustReturn: [])
        
        let trackActivity = RxActivityIndicator()
        
        let addRequestResult = input.didTapSend
            .asObservable()
            .withLatestFrom(currentCommentData)
            .flatMapFirst { [weak self] tuple -> Observable<Event<AddCommentModel?>> in
                guard let self = self else { return .empty() }
                let (title, comment) = tuple
                
                return self.addComment(title: title, comment: comment)
                    .trackActivity(trackActivity)
            }
            .share(replay: 1)
        
        let commentAdded = addRequestResult
            .compactMap { event -> Void? in
                guard let element = event.element, element?.result == true else { return nil }
                return ()
            }
            .asSignal(onErrorSignalWith: .empty())
        
        let showError = addRequestResult
            .compactMap { event -> String? in
                guard let element = event.element, let model = element, !model.result else {
                    return nil
                }
                
                return model.errorMessage
            }
            .asSignal(onErrorSignalWith: .empty())
        
        return Output(
            dataSource: dataSource,
            isSendEnabled: isSendEnabled,
            isLoading: trackActivity.asDriver(),
            commentAdded: commentAdded,
            showError: showError
        )
    }
}

// MARK: Private
private extension NewCommentScreenViewModel {
    func makeDataSource(currentTheme: Observable<NewCommentTheme>) -> Observable<[NewCommentCellType]> {
        currentTheme.map { theme -> [NewCommentCellType] in
            let isOther = theme == .other
            
            return [
                .selector(current: theme),
                isOther ? .header("title".localized.uppercased()) : nil,
                isOther ? .title : nil,
                .header("comment".localized.uppercased()),
                .comment
            ].compactMap { $0 }
        }
    }
    
    func addComment(title: String, comment: String) -> Observable<Event<AddCommentModel?>> {
        return commentManager
            .addComment(regNumber: regNumber, vin: vin, title: title, comment: comment)
            .asObservable()
            .materialize()
    }
}
