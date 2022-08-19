# Portkey
Portkey is a serverless file-sharing macOS application built with Swift and AWS.

![Portkey](portkey.gif)

The application uses AWS S3 bucket storage, Lambda Functions, CloudFront and Route53 to allow users to upload files to a staticly-hosted, custom domain web page. 


## Structure
`lambda/` contains the AWS Lambda function Node.JS runtime which handles all S3 static website configuration, CloudFront and Route53 processes.

`Portkey/` contains the macOS application code that interacts with the Lambda function. 

