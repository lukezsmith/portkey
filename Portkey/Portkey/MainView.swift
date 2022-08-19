//
//  ContentView.swift
//  Portkey
//
//  Created by Luke Smith on 19/07/2022.
//

import SwiftUI
import UniformTypeIdentifiers
import LoremSwiftum

struct MainView: View {
    @State var fileUrl: String;
    @State var tabSelection: Int
    @State var textData: Data
    @State private var subdomain = ""
    

    @State var onAppearRan = false
    
    var body: some View {
        Color.clear
            .overlay(
                VStack {
                    if self.onAppearRan{
                        Text("onAppear ran!")
                    }else{
                        //                    Text(fileUrl)
                        CustomTabView(tabSelection: tabSelection,
                                      tabBarPosition: .bottom,
                                      content: [
                                        (
                                            tabText: "􀀁",
                                            tabIconName: "",
                                            view: AnyView(
                                                FilePickerView(tabSelection: $tabSelection, textData: $textData)
                                            )
                                        ),
                                        (
                                            tabText: "􀀁",
                                            tabIconName: "",
                                            view: AnyView(
                                                SubdomainView(tabSelection: $tabSelection, subdomain: $subdomain)
                                            )
                                        ),
                                        (
                                            tabText: "􀀁",
                                            tabIconName: "",
                                            view: AnyView(
                                                UploadedView(tabSelection: $tabSelection, textData: textData, subdomain: subdomain)
                                            )
                                        )
                                      ]
                        )
                    }
                }
            )
        
    }
        
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(fileUrl: "test", tabSelection: 0, textData: Data())
    }
}
