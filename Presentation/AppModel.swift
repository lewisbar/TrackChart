//
//  AppModel.swift
//
//  Created by Lennart Wisbar on 30.09.25.
//

import Domain

@Observable
public class AppModel {
    public var path: [NavigationTopic] { get { navigator.path } set { navigator.path = newValue } }
    public var topicCellModels = [TopicCellModel]() { didSet {
        if !isUpdatingCellModelsFromStore {
            updateStoreWithDeletedAndReorderedCellModels()
        }
    } }
    private(set) public var currentTopic: Topic? { didSet { syncNameAndEntriesToCurrentTopic() } }
    public var currentTopicName: String = "" { didSet { currentTopic.map { rename($0, to: currentTopicName) } } }
    public var currentEntries: [Int] = [] { didSet { currentTopic.map { updateEntries(for: $0, to: currentEntries) } } }
    private(set) public var alertMessage = defaultAlertMessage
    public var isAlertViewPresented = false

    private let store: TopicStore
    private let navigator: Navigator
    private var isUpdatingCellModelsFromStore = false

    public init(store: TopicStore, navigator: Navigator) {
        self.store = store
        self.navigator = navigator
    }

    public func navigate(toTopicWithID id: UUID) {
        store.topic(for: id).map(navigate)
    }

    public func navigate(to topic: Topic) {
        navigator.showDetail(for: NavigationTopic(from: topic))
        currentTopic = topic
    }

    public func navigateToNewTopic() {
        let newTopic = Topic(id: UUID(), name: "", entries: [], unsubmittedValue: 0)
        do {
            try store.add(newTopic)
            navigator.showDetail(for: NavigationTopic(from: newTopic))
            currentTopic = newTopic
        } catch {
            handle(error)
        }
    }

    public func navigateBack() {
        navigator.goBack()
        currentTopic = navigator.path.last?.topic
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

    public func setUnsubmittedValue(to newValue: Int, for topic: Topic) {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: topic.entries, unsubmittedValue: newValue)
        do { try store.update(updatedTopic) } catch { handle(error) }
        // Cell models don't need to be updated, as they don't contain unsubmitted values
    }

    public func submit(_ value: Int, to topic: Topic) {
        do { try store.submit(value, to: topic) } catch { handle(error)}
        updateCellModelsFromStore()
    }

    public func removeLastValue(from topic: Topic) {
        do { try store.removeLastValue(from: topic) } catch { handle(error)}
        updateCellModelsFromStore()
    }

    private func rename(_ topic: Topic, to newName: String) {
        do { try store.rename(topic, to: newName) } catch { handle(error) }
        updateCellModelsFromStore()
    }

    private func updateEntries(for topic: Topic, to newEntries: [Int]) {
        let updatedTopic = Topic(id: topic.id, name: topic.name, entries: newEntries, unsubmittedValue: topic.unsubmittedValue)
        do { try store.update(updatedTopic) } catch { handle(error) }
        updateCellModelsFromStore()
    }

    private func updateStoreWithDeletedAndReorderedCellModels() {
        let backup = store.topics
        let updatedIDs = topicCellModels.map(\.id)

        do {
            try store.topics.forEach { topic in
                if !updatedIDs.contains(topic.id) {
                    try store.remove(topic)
                }
            }

            let reorderedTopics = updatedIDs.compactMap { store.topic(for: $0) }
            try store.reorder(to: reorderedTopics)
        } catch {
            store.topics = backup
            updateCellModelsFromStore()
            handle(error)
        }
    }

    private func updateCellModelsFromStore() {
        isUpdatingCellModelsFromStore = true
        topicCellModels = store.topics.map(TopicCellModel.init)
        isUpdatingCellModelsFromStore = false
    }

    private func syncNameAndEntriesToCurrentTopic() {
        currentTopicName = currentTopic?.name ?? ""
        currentEntries = currentTopic?.entries ?? []
    }

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }

    public static let defaultAlertMessage = (title: "Error", message: "An error occurred.")
}
