FROM python:3.7.3-slim

ENV TERRAFORM_COMPLIANCE_VERSION=1.3.6
ENV TERRAFORM_VERSION=0.12.24
ARG AZURE_CLI_VERSION=2.14.1
ENV CHECKOV_VERSION=
ENV TARGET_ARCH='linux_amd64'

RUN set -ex 
RUN apt-get update 
RUN apt-get install -y apt-transport-https
RUN apt-get install -y build-essential
RUN apt-get install -y curl
RUN apt-get install -y ca-certificates
RUN apt-get install -y lsb-release
RUN apt-get install -y rlwrap
RUN apt-get install -y nano
RUN apt-get install -y vim
RUN apt-get install -y jq
RUN apt-get install -y git
RUN apt-get install -y unzip 
RUN apt-get install -y gpg

COPY hashicorp-pgp-key.pub hashicorp-pgp-key.pub
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN curl -Os https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig
RUN gpg --import hashicorp-pgp-key.pub 
RUN gpg --verify terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig terraform_${TERRAFORM_VERSION}_SHA256SUMS
RUN grep terraform_${TERRAFORM_VERSION}_linux_amd64.zip terraform_${TERRAFORM_VERSION}_SHA256SUMS | sha256sum -c -
RUN unzip -j terraform_${TERRAFORM_VERSION}_linux_amd64.zip
RUN install terraform /usr/bin/ 
RUN pip --no-cache-dir install --upgrade pip 
RUN pip --no-cache-dir install terraform-compliance=="${TERRAFORM_COMPLIANCE_VERSION}" 
RUN pip --no-cache-dir uninstall -y radish radish-bdd 
RUN pip --no-cache-dir install radish radish-bdd 
RUN pip --no-cache-dir install checkov 
RUN pip --no-cache-dir install azure-cli==$AZURE_CLI_VERSION

RUN curl --location https://github.com/terraform-linters/tflint/releases/download/v0.20.3/tflint_darwin_amd64.zip --output tflint_darwin_amd64.zip
RUN unzip tflint_darwin_amd64.zip
RUN install tflint /usr/local/bin

RUN apt-get autoremove -y 
RUN apt-get clean -y 
RUN rm -rf /var/lib/apt/lists/* 
RUN terraform-compliance -v 
RUN checkov -v
RUN terraform -v
RUN tflint -v

WORKDIR /workspace
ENTRYPOINT ["terraform-compliance"]
