//
//  AWSS3Wrapper.swift
//  Portkey
//
//  Created by Luke Smith on 03/08/2022.
//

import Foundation
import AWSS3
import ClientRuntime
import AWSClientRuntime

public class AWSS3Wrapper{
    let s3Client: S3Client
    var accessKey : String
    var secretKey : String
    
    public init(accessKey: String, secretKey: String) throws {
        self.accessKey = accessKey
        self.secretKey = secretKey
        let credConfig = AWSCredentialsProviderStaticConfig(
            accessKey: accessKey,
            secret: secretKey,
            sessionToken: nil,
            shutDownCallback: nil
        )

        let s3Config = try S3Client.S3ClientConfiguration(
            region: "eu-west-2",
            credentialsProvider: AWSCredentialsProvider.fromStatic(credConfig)
        )

        s3Client = S3Client(config: s3Config)
        }
    
    public func getSubdomains() async throws ->[String]{
        var subdomains = [String]()
        let output = try await self.s3Client.listObjects(input: ListObjectsInput(bucket: "portkey-temp"))
        for obj in output.contents ?? []{
            let key = obj.key!.components(separatedBy: "/")[0]
            if !subdomains.contains(key){
                subdomains.append(key)
            }
        }
        return subdomains
    }
    
    public func uploadFile(bucket: String, body: ByteStream, key: String) async throws{
        let input = PutObjectInput(body: body,
                                   bucket: bucket, key: key)
        
        try await self.s3Client.putObject(input: input)
        
    }
}
