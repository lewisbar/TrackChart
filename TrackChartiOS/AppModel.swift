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

    public init(store: TopicStore, navigator: Navigator) {
        self.store = store
        self.navigator = navigator
    }

    public func loadTopics() {
        do { try store.load() } catch { handle(error) }
    }

    public func rename(_ topic: Topic, to newName: String) {
        do { try store.rename(topic, to: newName) } catch { handle(error) }
    }

    public func submit(_ value: Int, to topic: Topic) {
        do { try store.submit(value, to: topic) } catch { handle(error)}
    }

    public func removeLastValue(from topic: Topic) {
        do { try store.removeLastValue(from: topic) } catch { handle(error)}
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

    private func handle(_ error: Error) {
        alertMessage = ("Error", error.localizedDescription)
        isAlertViewPresented = true
    }
}
