import Foundation
import SwiftUI

internal final class ProjectSelectorModel<V: Equatable>: ObservableObject {
    @Published var projects: [Project<V>] = []
    @Published var selectedProject: Project<V>?

    @Published var projectsVisible: Bool = true

    @Published var projectConfirmed: Bool = false

    @Published var width: CGFloat = 100

    var textBinding: Binding<String>?

    internal func modifiedText(_ text: String) {
        self.textBinding?.wrappedValue = text

        self.selectedProject = nil
        self.projectsVisible = true
        self.projectConfirmed = false
    }

    internal func cancel() {
        NSApplication.shared.terminate(nil)
    }

    internal func moveUp() {
        self.projectConfirmed = false

        guard let selectedProject = self.selectedProject else {
            return
        }

        guard let project = self.previousProject(for: selectedProject) else {
            self.selectedProject = nil
            return
        }
        self.selectedProject = project
    }

    internal func moveDown() {
        self.projectConfirmed = false

        guard let selectedProject = self.selectedProject else {
            guard let project = self.firstProject else {
                return
            }
            self.selectedProject = project
            return
        }

        guard let project = self.nextProject(for: selectedProject) else {
            return
        }
        self.selectedProject = project
    }

    internal var firstProject: Project<V>? {
        let projects = self.projects
        return projects.first
    }

    internal func nextProject(for project: Project<V>) -> Project<V>? {
        let projects = self.projects
        guard let index = projects.firstIndex(of: project),
              index + 1 < projects.count else {
            return nil
        }
        return projects[index + 1]
    }

    internal func previousProject(for project: Project<V>) -> Project<V>? {
        let projects = self.projects
        guard let index = projects.firstIndex(of: project),
              index - 1 >= 0 else {
            return nil
        }
        return projects[index - 1]
    }

    internal func chooseProject(_ project: Project<V>?) {
        self.selectedProject = project
        self.projectConfirmed = false
    }

    internal func confirmProject(_ project: Project<V>, modifier: Bool) {

        self.selectedProject = project
        self.projectsVisible = false

        self.textBinding?.wrappedValue = project.text

        self.projectConfirmed = true

        Task {
            do {
                try await openProject(name: project.text, landInTerminal: modifier)
                await NSApplication.shared.terminate(nil)
            } catch {
                print("Error while opening project: " + project.text)
            }
        }
    }

    internal func openProject(name: String, landInTerminal: Bool) async throws {
        var url = "http://localhost:7777/project/" + name
        url = url + (landInTerminal ? "?land-in=terminal" : "?land-in=editor")
        let _ = try await URLSession.shared.data(from: URL(string: url)!)
    }


}
