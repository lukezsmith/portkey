//
//  UploadedView.swift
//  Portkey
//
//  Created by Luke Smith on 28/07/2022.
//

import SwiftUI
import AWSS3
import ClientRuntime
import AWSClientRuntime

struct UploadedView: View {
    // Binding variable to change tabs in MainView
    @Binding var tabSelection: Int
    @State var textData: Data
    @State var subdomain: String
    
    @State var hasUploaded = false
    
    func s3FileUpload() async {
        let bucketName = "portkey-temp"
        guard let dataToUpload = String(decoding: self.textData, as: UTF8.self).data(using: .utf8) else {
            return
        }
        let body = ByteStream.from(data: dataToUpload)
        var s3Wrapper : AWSS3Wrapper
        do {
            s3Wrapper = try AWSS3Wrapper(accessKey: Env.awsAccessKeyId, secretKey: Env.awsSecretAccessKey)
            try await s3Wrapper.uploadFile(bucket: bucketName, body: body, key: subdomain+"/"+"content.txt")
            sleep(5)
            self.hasUploaded = true
        } catch{
            dump(error)
        }
    }
    
    var body: some View {
        VStack {
            if self.hasUploaded {
                let portkeyUrl = subdomain+".portkey.app"
                let s3Url = subdomain+".portkey.app.s3-website.eu-west-2.amazonaws.com"
                Text("Upload of text file to ") + Text(.init("[" + portkeyUrl+"](https://"+portkeyUrl+")")).underline() +  Text(" will take 5-10 minutes.\n")
                Text("However, you can access and share your text file immediately with ") + Text(.init("[" + s3Url+"](http://"+s3Url+")")).underline()
                
            }else{
                Text("Uploading...")
                ProgressView()
            }
        }
        .onAppear {
            Task{
                await self.s3FileUpload()
            }
        }
    }
}

struct UploadedView_Previews: PreviewProvider {
    @State static var previewData = Data()
    static var previews: some View {
        UploadedView(tabSelection: Binding.constant(0), textData: previewData, subdomain: "test")
    }
}
