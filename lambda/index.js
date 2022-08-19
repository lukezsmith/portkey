require("dotenv").config();

// dependencies
const AWS = require("aws-sdk");
let fs = require("fs");
const cheerio = require("cheerio");

// get reference to S3 client
const s3 = new AWS.S3();

// get reference to cloudfront client
const cloudfront = new AWS.CloudFront();

// get reference to route53 client
const route53 = new AWS.Route53();

// function that converts text file to html
function textToHtml(content) {
  console.log("Stage 1: Creating html files...\n");

  // create tmp src dir
  if (!fs.existsSync("/tmp/src")) {
    fs.mkdirSync("/tmp/src", { recursive: true });
  }

  // add error file
  fs.copyFileSync(__dirname + "/error.html", "/tmp/src/error.html");

  // create index file
  var data = fs.readFileSync(__dirname + "/index_template.html");
  var $ = cheerio.load(data);
  $("p").text(content);
  fs.writeFileSync("/tmp/src/index.html", $.html(), "utf8");
}

// function to deploy created files into given s3 bucket
function deployFiles(bucketName) {
  console.log("Stage 2: Deploying files...\n");
  // Create the parameters for calling createBucket
  bucketName = bucketName + ".portkey.app";
  var bucketParams = {
    Bucket: bucketName,
    CreateBucketConfiguration: {
      LocationConstraint: "eu-west-2",
    },
  };

  let indexData = fs.readFileSync("/tmp/src/index.html");
  // call S3 to create the bucket
  s3.createBucket(bucketParams, function (err, data) {
    if (err) {
      console.log("createBucketError", err.stack);
    } else {
      // upload files
      s3.putObject(
        {
          Bucket: bucketName,
          Key: "index.html",
          Body: indexData,
          ContentType: "text/html",
        },
        function (res) {
          let errorData = fs.readFileSync("/tmp/src/error.html");

          s3.putObject(
            {
              Bucket: bucketName,
              Key: "error.html",
              Body: errorData,
              ContentType: "text/html",
            },
            function (res) {
              // add bucket policy
              const bucketPolicy = {
                Version: "2012-10-17",
                Statement: [
                  {
                    Sid: "PublicReadGetObject",
                    Effect: "Allow",
                    Principal: "*",
                    Action: ["s3:GetObject"],
                    Resource: [`arn:aws:s3:::${bucketName}/*`],
                  },
                ],
              };
              // Create the parameters for calling putBucketPolicy
              var bucketParams = {
                Bucket: bucketName,
                Policy: JSON.stringify(bucketPolicy),
              };

              // set the new policy on the selected bucket
              s3.putBucketPolicy(bucketParams, function (err, data) {
                if (err) {
                  // display error message
                  console.log("putBucketPolicy Error", err);
                } else {
                  // create static website config
                  var staticHostParams = {
                    Bucket: bucketName,
                    WebsiteConfiguration: {
                      ErrorDocument: {
                        Key: "error.html",
                      },
                      IndexDocument: {
                        Suffix: "index.html",
                      },
                    },
                  };

                  // set the new website configuration on the selected bucket
                  s3.putBucketWebsite(staticHostParams, function (err, data) {
                    if (err) {
                      // display error message
                      console.log("putBucketWebsite Error", err);
                    } else {
                      // update the displayed website configuration for the selected bucket
                      console.log("File has successfully been uploaded.");
                      // create distribution and subdomain dns records
                      createCloudFrontDistribution(bucketName)
                    }
                  });
                }
              });
            }
          );
        }
      );
    }
  });
}

// function to update cloudfront distribution with new subdomain
function createCloudFrontDistribution(bucketName) {
  
  let distributionParams = {
    DistributionConfig: {
      CallerReference: Date.now().toString(),
      Aliases: { Quantity: 1, Items: [ bucketName ] },
      Origins: {
        Quantity: 1,
        Items: [
          {
            Id: `${bucketName}.s3-website.eu-west-2.amazonaws.com`,
            DomainName: `${bucketName}.s3-website.eu-west-2.amazonaws.com`,
            OriginPath: "",
            CustomHeaders: { Quantity: 0, Items: [] },
            CustomOriginConfig: {
              HTTPPort: 80,
              HTTPSPort: 443,
              OriginProtocolPolicy: 'http-only',
              OriginSslProtocols: { Quantity: 3, Items: [ 'TLSv1', 'TLSv1.1', 'TLSv1.2' ] },
              OriginReadTimeout: 30,
              OriginKeepaliveTimeout: 5
            },
            ConnectionAttempts: 3,
            ConnectionTimeout: 10,
            OriginShield: { Enabled: false },
          },
        ],
      },
      DefaultCacheBehavior: {
        TargetOriginId: `${bucketName}.s3-website.eu-west-2.amazonaws.com`,
        TrustedSigners: { Enabled: false, Quantity: 0, Items: [] },
        TrustedKeyGroups: { Enabled: false, Quantity: 0, Items: [] },
        ViewerProtocolPolicy: 'redirect-to-https',
        AllowedMethods: {
              Quantity: 2,
              Items: [ 'HEAD', 'GET' ],
              CachedMethods: { Quantity: 2, Items: [ 'HEAD', 'GET' ] }
            },
        SmoothStreaming: false,
        Compress: true,
        LambdaFunctionAssociations: { Quantity: 0, Items: [] },
        FunctionAssociations: { Quantity: 0, Items: [] },
        FieldLevelEncryptionId: '',
        CachePolicyId: '658327ea-f89d-4fab-a63d-7e88639e58f6'
      },
      ViewerCertificate: {
        CloudFrontDefaultCertificate: false,
        ACMCertificateArn: 'arn:aws:acm:us-east-1:878128752796:certificate/b2f77433-1c5c-4371-bf0f-d80940c01c8a',
        SSLSupportMethod: 'sni-only',
        MinimumProtocolVersion: 'TLSv1.2_2021',
        Certificate: 'arn:aws:acm:us-east-1:878128752796:certificate/b2f77433-1c5c-4371-bf0f-d80940c01c8a',
        CertificateSource: 'acm'
      },
      Comment: "",
      Enabled: true,
    },
  };

  // create distribution
  cloudfront.createDistribution(distributionParams, function(err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else{
      console.log("CloudFront Distribution Created.")
      // create necessary alias dns record
      updateDNS(bucketName, data.Distribution.DomainName);
    }
  });
}

function updateDNS(bucketName, cloudfrontDistributionURL) {
  let route53Params = {
    HostedZoneId: process.env.ROUTE_53_HOSTEDZONE_ID,
    ChangeBatch: {
      Changes: [
        {
          Action: "CREATE",
          ResourceRecordSet: {
            Name: bucketName,
            Type: "A",
            AliasTarget: {
              DNSName: cloudfrontDistributionURL,
              HostedZoneId: "Z2FDTNDATAQYW2",
              EvaluateTargetHealth: false,
            },
          },
        },
      ],
    },
  };

  route53.changeResourceRecordSets(route53Params, function (err, data) {
    if (err) console.log(err, err.stack); // an error occurred
    else {
      console.log("Subdomain DNS Records Created.")
    }
  });
}

exports.handler = (event, context, callback) => {
  console.log("Running Portkey deployment Lambda function...\n\n");

  // Read options from the event parameter.
  const srcBucket = event.Records[0].s3.bucket.name;
  // TODO: may require some more advanced filename santisation
  // Object key may have spaces or unicode non-ASCII characters.
  const srcKey = decodeURIComponent(
    event.Records[0].s3.object.key.replace(/\+/g, " ")
  );
  const dstBucket = srcKey.split("/")[0];

  // Download the image from the S3 source bucket.
  const params = {
    Bucket: srcBucket,
    Key: srcKey,
  };

  s3.getObject(params, function(err, data) {
    if (err) throw err;
    else{
      // convert text to html
      textToHtml(data.Body.toString("ascii"))
      // deploy
      deployFiles(dstBucket);
    }
  });
  
};
