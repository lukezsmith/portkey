//
//  SubdomainView.swift
//  Portkey
//
//  Created by Luke Smith on 28/07/2022.
//

import SwiftUI
import AWSS3
import ClientRuntime
import AWSClientRuntime
import LoremSwiftum


// function to hyphenate random words to build a subdomain
func hyphenateWords(from array: [String]) -> String {
    return array
        .enumerated()
        .map {(index, element) in
            if index == 0 {
                return element
            } else {
                return "-" + element
            }
        }.joined()
}

struct SubdomainView: View {
    // Binding variable to change tabs in MainView
    @Binding var tabSelection: Int
    @Binding var subdomain: String
    
    @State var existingSubdomains =  ["test", "portkey-temp"]
    @State var subdomainEdited : Bool
    @State var unavailableSubdomain : Bool
    
    @State var hasValidatedSubdomains : Bool

    
    init(tabSelection: Binding<Int>, subdomain: Binding<String>){
        self._tabSelection = tabSelection;
        self._subdomain = subdomain;
        self.hasValidatedSubdomains = false;
        self.subdomainEdited = false;
        self.unavailableSubdomain = false;
//        Task {
//            print("onAppear in subdomain running")
//
//            var s3Wrapper : AWSS3Wrapper
//            do {
//                s3Wrapper = try AWSS3Wrapper()
//                // get taken subdomains
//                let subdomains = try await s3Wrapper.getSubdomains()
//
//                // generate random subdomain until we have a unique one
//                var randomInt = Int(arc4random_uniform(4) + 1)
//                var words = Lorem.words(randomInt)
//                words = hyphenateWords(from:words.components(separatedBy: " "))
//                // iterate until we have unique subdomain
//                while subdomains.contains(words){
//                    randomInt = Int(arc4random_uniform(4) + 1)
//                    words = Lorem.words(randomInt)
//                    words = hyphenateWords(from:words.components(separatedBy: " "))
//                }
//                // set subdomain
//                DispatchQueue.main.async {
//                    self.subdomain = words
//                    self.isValidatingSubdomains = false;
//                }
//
//            } catch {
//                dump(error)
//            }
//        }
    }
    var body: some View {
        // subdomain selector
        VStack{
            if !self.hasValidatedSubdomains{
//                let: ()  = getData()
//                return ProgressView()
                ProgressView()
            }else{
                Text("Enter the custom URL you want to upload your file to below")
                    .multilineTextAlignment(.leading)
                
                HStack{
                    
                    Form {
                        TextField("", text: $subdomain, onEditingChanged: {_ in
                            self.subdomainEdited = true
                        })
                        .foregroundColor(self.subdomainEdited ? ((self.unavailableSubdomain) ? Color.red : Color.black) : Color.gray )
                        .onChange(of: subdomain) {
                            // check valid and available subdomain
                            if self.existingSubdomains.contains($0) || !$0.isAlphanumeric(ignoreDiacritics: true){
                                self.unavailableSubdomain = true
                            }else{
                                self.unavailableSubdomain = false
                            }
                        }
                        
                    }
                    Text(".portkey.app")
                        .bold()
                    
                }
                .frame(maxWidth: 350.0)
                if self.unavailableSubdomain{
                    Text("Subdomain unavailable. Please enter another.")
                        .font(.headline)
                        .padding()
                }
                Button( action:
                            {
                    self.tabSelection = 2
                }){
                    Text("Upload")
                }
                .disabled(self.unavailableSubdomain)
            }
        }
        .padding(.all, 20.0)
        .onAppear {
            if !hasValidatedSubdomains{
                Task{
                    var s3Wrapper : AWSS3Wrapper
                    do {
                        s3Wrapper = try AWSS3Wrapper(accessKey: Env.awsAccessKeyId, secretKey: Env.awsSecretAccessKey)
                        // get taken subdomains
                        existingSubdomains = try await s3Wrapper.getSubdomains()

                        // generate random subdomain until we have a unique one
                        var randomInt = Int(arc4random_uniform(4) + 1)
                        var words = Lorem.words(randomInt)
                        words = hyphenateWords(from:words.components(separatedBy: " "))
                        // iterate until we have unique subdomain
                        while existingSubdomains.contains(words){
                            randomInt = Int(arc4random_uniform(4) + 1)
                            words = Lorem.words(randomInt)
                            words = hyphenateWords(from:words.components(separatedBy: " "))
                        }
                        // set subdomain
                        subdomain = words
                        self.hasValidatedSubdomains = true;
                    } catch {
                        dump(error)
                    }
                    
                }
            }
        }
    }
    
//    struct SubdomainView_Previews: PreviewProvider {
//
//        do{
//            try{
//                static var s3Wrapper = AWSS3Wrapper()
//                static var previews: some View {
//                    SubdomainView(tabSelection: Binding.constant(1), subdomain: Binding.constant("test"), s3Wrapper: s3Wrapper)
//                }
//            }
//        }
//    }
}

