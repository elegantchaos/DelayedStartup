// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

struct ContentView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    @State var editing: Bool = false
    
    var body: some View {
        VStack {
            Text("Startup Items:")
            List() {
                ForEach(model.items) { item in
                    HStack {
                        if self.editing {
                            SystemImage(.rowHandle)
                            Button(action: { self.model.delete(item: item) })  {
                                SystemImage(.rowDelete)
                                    .foregroundColor(Color.red)
                            }.buttonStyle(BorderlessButtonStyle())
                        }
                        
                        Text(item.name)
                    }
                }
                .onDelete(perform: { at in self.model.delete(at: at) })
                .onMove(perform: self.editing ? { from, to in self.model.move(from: from, to: to)} : nil)
            }.bindEditing(to: $editing)


            Spacer()
            
            HStack {
                Button(action: add) {
                    Text("Add")
                }
                
                Button(action: test) {
                    Text("Test")
                }
                
                Button(action: { self.editing = !self.editing }) {
                    Text("Edit")
                }
            }

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
    
    func add() {
        viewState.selectItemsToAdd()
    }
    
    func test() {
        model.performStartup()
    }
}

protocol EditableModel {
    associatedtype Item
    func delete(item: Item)
    func delete(at offsets: IndexSet)
}

struct EditableRowView<ContentView, Model>: View where ContentView: View, Model: EditableModel {
    let item: Model.Item
    let model: Model
    let content: () -> ContentView
    @Environment(\.editModeShim) var editMode: EditModeShim
    
    var body: some View {
        HStack {
            if self.editMode.isEditing {
                SystemImage(.rowHandle)
                Button(action: { self.model.delete(item: self.item) })  {
                    SystemImage(.rowDelete)
                        .foregroundColor(Color.red)
                }.buttonStyle(BorderlessButtonStyle())
            }
            
            content()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
