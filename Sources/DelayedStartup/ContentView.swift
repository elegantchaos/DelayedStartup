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
            VStack(alignment: .leading) {
                
                Text("Delayed Startup Items")
                
                EditableList() { (item: Model.Item, model: Model) in
                    Image(nsImage: item.icon)
                    Text(item.name)
                }
                
                Spacer()
                
                HStack {
                    Button(action: self.add) {
                        Text("Add")
                    }
                    
                    EditButton() {
                        Text("Edit")
                    }
                    
                    Spacer()
                    
                    Button(action: self.test) {
                        Text("Test")
                    }
                }

                Spacer()
                
                HStack {
                    Toggle("Delay For", isOn: self.$model.delayEnabled)
                    TextField("Delay", text: self.$model.delay).frame(width: 64)
                    Text("seconds")
                }

                HStack {
                    Toggle("Wait For Volume", isOn: self.$model.volumeEnabled)
                    TextField("Volume", text: self.$model.volume)
                }

                HStack {
                    Toggle("Quit When Done", isOn: self.$model.quitWhenDone)
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
        model.firstCheck()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
