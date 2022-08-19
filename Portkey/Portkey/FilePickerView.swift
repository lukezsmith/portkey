//
//  FilePickerView.swift
//  Portkey
//
//  Created by Luke Smith on 27/07/2022.
//

import SwiftUI
import UniformTypeIdentifiers

struct FilePickerView: View {
    // Binding variable to change tabs in MainView
    @Binding var tabSelection: Int
    // Binding variable to store text file data
    @Binding var textData: Data

    @State var filename = "Filename"
    @State var showFileChooser = false
    @State var fileUploaded = false
    @State var showError = false
    
    let txtType = UTType("public.plain-text")
    
    func loadFileFromLocalPath(_ localFilePath: String) ->Data? {
        return try? Data(contentsOf: URL(fileURLWithPath: localFilePath))
    }
    func processFileUpload(filename: String){
        _ = URL(string: filename)
    }
    var body: some View {
        VStack {
            Text("Select the file you want to share with the file picker below")
                .multilineTextAlignment(.leading)
            
            
            Button( action:
                        {
                
                let openPanel = NSOpenPanel()
                openPanel.prompt = "Select File"
                openPanel.allowsMultipleSelection = false
                openPanel.canChooseDirectories = false
                openPanel.canCreateDirectories = false
                openPanel.canChooseFiles = true
                openPanel.allowedContentTypes =     [txtType! as UTType]
                openPanel.begin { (result) -> Void in
                    if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                        let selectedPath = openPanel.url!.path
                        self.textData = self.loadFileFromLocalPath(selectedPath)!
                        self.fileUploaded = true
                        self.tabSelection = 1
                    }else {
                        self.showError = true
                    }
                }
            }){
                Text("Select File")
            }
            .padding(.all, 30.0)
        }
    }
}

struct FilePickerView_Previews: PreviewProvider {

    static var previews: some View {
        FilePickerView(tabSelection: Binding.constant(0), textData: Binding.constant(Data()))
    }
}
