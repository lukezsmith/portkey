//
//  PortkeyApp.swift
//  Portkey
//
//  Created by Luke Smith on 19/07/2022.
//

import SwiftUI
import LoremSwiftum

@main
struct PortkeyApp: App {
    @State var openedFile = ""
    @State var openedFileData = Data()
    @State var subdomain = ""
    var body: some Scene {
        WindowGroup {
            if openedFile == ""{
                MainView(fileUrl: "", tabSelection: 0, textData: Data())
                    .onOpenURL { url in
                        // set fileUrl
                        openedFile = url.absoluteString
                        openedFileData = try! Data(contentsOf: url)
//                        subdomain = await getData()
                    }
            }else{
                MainView(fileUrl:openedFile, tabSelection:1, textData:openedFileData)
            }
        }
    }
}
