#!/bin/bash
# shellcheck shell=bash
# --------------------------------------------------------------------
## AWS Cloud Platform
# --------------------------------------------------------------------

# Basic AWS commands
alias aw='aws'
alias awstop='aws ec2 stop-instances --instance-ids'
alias awstart='aws ec2 start-instances --instance-ids'
alias aws3ls='aws s3 ls'
alias aws3cp='aws s3 cp'
alias awlambda='aws lambda list-functions --query "Functions[*].[FunctionName,Runtime]" --output table'
alias awsl='aws sso login'
awprofile() {
    if [ -z "${1-}" ]; then
        echo "Usage: awprofile <profile-name>" >&2
        return 1
    fi
    export AWS_PROFILE="$1"
    echo "AWS_PROFILE=$AWS_PROFILE"
}

# AWS utility functions
aws-ec2-ip() {
    if [ -z "$1" ]; then
        echo "Usage: aws-ec2-ip <instance_id>"
        return 1
    fi
    aws ec2 describe-instances --instance-ids "$1" --query "Reservations[*].Instances[*].PublicIpAddress" --output text
}

aws-s3-size() {
    if [ -z "$1" ]; then
        echo "Usage: aws-s3-size <bucket_name>"
        return 1
    fi
    aws s3 ls --summarize --human-readable --recursive "s3://$1" | tail -1
}
