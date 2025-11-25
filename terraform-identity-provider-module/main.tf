# 
# Copyright 2025 EDT&Partners
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# 
data "aws_caller_identity" "current" {}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["c3768084dfb3d2b68b7897bf5f565da8eexample"]
  url             = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_role" "this" {
  name               = "iam-deploy-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:EDT-Partners-Tech/*:*"
                }
            }
        }
    ]
}
EOF
}
resource "aws_iam_policy" "this" {
  name        = "${var.project}-iam-deploy-policy"
  path        = "/"
  description = "IAM policy to deploy apps"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
       {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "ecr:*",
            "Resource": "*"
        }, {
            "Effect": "Allow",
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:*",
                "s3:DeleteObject"
            ],
            "Resource": "arn:aws:s3:::itc-*/*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "lambda:UpdateFunctionCode"
            ],
            "Resource": "arn:aws:lambda:*:*:function:*"
        }, {
            "Effect": "Allow",
            "Action": [
                "cloudformation:DescribeStacks",
                "cloudformation:ListStackResources",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricData",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "kms:ListAliases",
                "iam:GetPolicy",
                "iam:GetPolicyVersion",
                "iam:GetRole",
                "iam:GetRolePolicy",
                "iam:ListAttachedRolePolicies",
                "iam:ListRolePolicies",
                "iam:ListRoles",
                "lambda:*",
                "logs:DescribeLogGroups",
                "states:DescribeStateMachine",
                "states:ListStateMachines",
                "tag:GetResources",
                "xray:GetTraceSummaries",
                "xray:BatchGetTraces"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:PassedToService": "lambda.amazonaws.com"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:DescribeLogStreams",
                "logs:GetLogEvents",
                "logs:FilterLogEvents"
            ],
            "Resource": "arn:aws:logs:*:*:log-group:/aws/lambda/*"
        }, {
            "Sid": "cfflistbuckets",
            "Action": [
                "s3:ListAllMyBuckets"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:s3:::*"
        },
        {
            "Sid": "cffullaccess",
            "Action": [
                "acm:ListCertificates",
                "cloudfront:*",
                "cloudfront-keyvaluestore:*",
                "iam:ListServerCertificates",
                "waf:ListWebACLs",
                "waf:GetWebACL",
                "wafv2:ListWebACLs",
                "wafv2:GetWebACL",
                "kinesis:ListStreams"
            ],
            "Effect": "Allow",
            "Resource": "*"
        },
        {
            "Sid": "cffdescribestream",
            "Action": [
                "kinesis:DescribeStream"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:kinesis:*:*:*"
        },
        {
            "Sid": "cfflistroles",
            "Action": [
                "iam:ListRoles"
            ],
            "Effect": "Allow",
            "Resource": "arn:aws:iam::*:*"
        },  {
            "Effect": "Allow",
            "Action": [
                "s3:*",
                "s3-object-lambda:*"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssm:GetParametersByPath",
                "ssm:GetParameter",
                "ssm:DescribeParameters"
            ],
            "Resource": "arn:aws:ssm:*:*:parameter/*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}
##########################################TERRAFORM####################################
resource "aws_iam_role" "iac" {
  name               = "github-deploy-role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/token.actions.githubusercontent.com"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
                },
                "StringLike": {
                    "token.actions.githubusercontent.com:sub": "repo:EDT-Partners-Tech/*"
                }
            }
        }
    ]
}
EOF
}

resource "aws_iam_policy" "iac" {
  name        = "${var.project}-iam-iac-deploy-policy"
  path        = "/"
  description = "IAM policy to deploy apps"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "1234567890",
            "Effect": "Allow",
            "Action": "*",
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "iac" {
  role       = aws_iam_role.iac.name
  policy_arn = aws_iam_policy.iac.arn
}
