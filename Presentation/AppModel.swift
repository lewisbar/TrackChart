//
//  AppModel.swift
//
//  Created by Lennart Wisbar on 30.09.25.
//

import Domain

@Observable
public class AppModel {
    private let store: TopicStore
    public var navigator: Navigator
    public var alertMessage = (title: "Error", message: "An error occurred.")
    public var isAlertViewPresented = false
    public var topicCellModels = [TopicCellModel]() {
        didSet { updateStoreWithDeletedAndReorderedCellModels() }
    }
    public var currentTopic: Topic? {
        didSet { currentTopicName = currentTopic?.name ?? "" }
    }
    public var currentTopicName: String = "" {
        didSet { currentTopic.map { rename($0, to: currentTopicName) } }
    }

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
        let newTopic = Topic(id: UUID(), name: "", entries: [])
        do { try store.add(newTopic) } catch { handle(error) }
        navigator.showDetail(for: NavigationTopic(from: newTopic))
        currentTopic = newTopic
    }

    public func navigateBack() {
        navigator.goBack()
        currentTopic = navigator.path.last?.topic
    }

    public func loadTopics() {
        do { try store.load() } catch { handle(error) }
        updateCellModelsFromStore()
    }

    public func topic(for id: UUID) -> Topic? {
        store.topic(for: id)
    }

    public func rename(_ topic: Topic, to newName: String) {
        do { try store.rename(topic, to: newName) } catch { handle(error) }
        updateCellModelsFromStore()
    }

    public func submit(_ value: Int, to topic: Topic) {
        do { try store.submit(value, to: topic) } catch { handle(error)}
        updateCellModelsFromStore()
    }

    public func removeLastValue(from topic: Topic) {
        do { try store.removeLastValue(from: topic) } catch { handle(error)}
        updateCellModelsFromStore()
    }

    private func updateStoreWithDeletedAndReorderedCellModels() {
        let updatedIDs = topicCellModels.map(\.id)

        store.topics.forEach { topic in
            if !updatedIDs.contains(topic.id) {
                do { try store.remove(topic) } catch { handle(error) }
            }
        }

        let reorderedTopics = updatedIDs.compactMap { store.topic(for: $0) }
        do { try store.reorder(to: reorderedTopics) } catch { handle(error) }
    }

    private func updateCellModelsFromStore() {
        topicCellModels = store.topics.map(TopicCellModel.init)
    }

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }
}
