// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Sam Deane on 05/06/2020.
//  All code (c) 2020 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import SwiftUI
import SwiftUIExtensions

extension Model: EditableModel {
}

struct ContentView: View {
    @EnvironmentObject var model: Model
    @EnvironmentObject var viewState: ViewState
    
    var body: some View {
        EditingView() {
            VStack {
                Text("Delayed Startup Items")
                
                EditableList() { (item: Model.Item, model: Model) in
                    Text(item.name)
                }
                
                Spacer()
                
                HStack {
                    Button(action: self.add) {
                        Text("Add")
                    }
                    
                    Button(action: self.test) {
                        Text("Test")
                    }
                    //
                    EditButton() {
                        Text("Edit")
                    }
                }
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
        }
    }
    
    func add() {
        viewState.selectItemsToAdd()
    }
    
    func test() {
        model.performStartup()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
