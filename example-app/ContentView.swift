//
//  ContentView.swift
//  example-app
//
//  Created by Nacho on 30/10/26.
//

import SwiftUI

struct ContentView: View {
    @State private var model = TodoListModel()

    var body: some View {
        NavigationStack {
            TodoListView(model: model)
                .navigationTitle("Tareas")
        }
    }
}

#Preview {
    ContentView()
}
