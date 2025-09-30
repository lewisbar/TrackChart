//
//  AppModel.swift
//  TrackChartiOS
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

    public init(store: TopicStore, navigator: Navigator) {
        self.store = store
        self.navigator = navigator
        loadTopics()
    }

    public func navigate(toTopicWithID id: UUID) {
        store.topic(for: id).map(navigate)
    }

    public func navigate(to topic: Topic) {
        navigator.showDetail(for: NavigationTopic(from: topic))
    }

    public func navigateToNewTopic() {
        let newTopic = Topic(id: UUID(), name: "", entries: [])
        do { try store.add(newTopic) } catch { handle(error) }
        navigator.showDetail(for: NavigationTopic(from: newTopic))
    }

    public func navigateBack() {
        navigator.goBack()
    }

    public func rename(_ topic: Topic, to newName: String) {
        do { try store.rename(topic, to: newName) } catch { handle(error) }
        topicCellModels = store.topics.map(TopicCellModel.init)
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

    private func loadTopics() {
        do { try store.load() } catch { handle(error) }
        topicCellModels = store.topics.map(TopicCellModel.init)
    }

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }
}
