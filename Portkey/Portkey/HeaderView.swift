//
//  HeaderView.swift
//  Portkey
//
//  Created by Luke Smith on 27/07/2022.
//

import SwiftUI

struct HeaderView: View {
    var body: some View {
        HStack{
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundColor(.accentColor)
            Text("Portkey")
        }
        .padding(.vertical, 20.0)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
    }
}
