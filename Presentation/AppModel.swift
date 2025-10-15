//
//  AppModel.swift
//
//  Created by Lennart Wisbar on 30.09.25.
//

import Domain

@Observable
public class AppModel {
    public var path: [NavigationTopic] { get { navigator.path } set { navigator.path = newValue } }
    private(set) public var topicListModel: TopicListViewModel = .placeholder
    private(set) public var alertMessage = defaultAlertMessage
    public var isAlertViewPresented = false

    private let store: TopicStore
    private let navigator: Navigator

    public init(store: TopicStore, navigator: Navigator) {
        self.store = store
        self.navigator = navigator
        self.topicListModel = TopicListViewModel(topics: [], updateTopicList: { [weak self] newOrder in
            self?.updateTopicList(to: newOrder)
        })
    }

    public func navigate(toTopicWithID id: UUID) {
        store.topic(for: id).map(navigate)
    }

    public func navigate(to topic: Topic) {
        navigator.showDetail(for: NavigationTopic(from: topic))
    }

    public func navigateToNewTopic() {
        let newTopic = Topic(id: UUID(), name: "", entries: [], unsubmittedValue: 0)
        do {
            try store.add(newTopic)
            navigator.showDetail(for: NavigationTopic(from: newTopic))
        } catch {
            handle(error)
        }
    }

    public func navigateBack() {
        navigator.goBack()
    }

    public func dismissAlert() {
        isAlertViewPresented = false
        alertMessage = Self.defaultAlertMessage
    }

    public func loadTopics() {
        do { try store.load() } catch { handle(error) }
        updateCellModelsFromStore()
    }

    public func topic(for id: UUID) -> Topic? {
        store.topic(for: id)
    }

    public func update(_ changedTopic: Topic) {
        do { try store.update(changedTopic) } catch { handle(error) }
        updateCellModelsFromStore()
    }

    private func updateTopicList(to newOrder: [UUID]) {
        let backup = store.topics

        do {
            try store.topics.forEach { topic in
                if !newOrder.contains(topic.id) {
                    try store.remove(topic)
                }
            }

            let reorderedTopics = newOrder.compactMap { store.topic(for: $0) }
            try store.reorder(to: reorderedTopics)
        } catch {
            store.topics = backup
            updateCellModelsFromStore()
            handle(error)
        }
    }

    private func updateCellModelsFromStore() {
        topicListModel.updateFromStore(topics: store.topics)
    }

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }

    public static let defaultAlertMessage = (title: "Error", message: "An error occurred.")
}

private extension TopicListViewModel {
    static let placeholder = TopicListViewModel(topics: [], updateTopicList: { _ in })
}
