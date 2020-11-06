FROM python:3.7.3-slim

ENV TERRAFORM_COMPLIANCE_VERSION=1.3.6
ENV TERRAFORM_VERSION=0.12.24
ENV CHECKOV_VERSION=
ENV TARGET_ARCH='linux_amd64'

RUN set -ex 
RUN apt-get update 
RUN apt-get install -y curl
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
RUN pip install --upgrade pip 
RUN pip install terraform-compliance=="${TERRAFORM_COMPLIANCE_VERSION}" 
RUN pip install radish radish-bdd 
RUN pip install checkov 
RUN apt-get autoremove -y 
RUN apt-get clean -y 
RUN rm -rf /var/lib/apt/lists/* 
RUN terraform-compliance -v 
RUN checkov -v
RUN terraform -v

WORKDIR /workspace
ENTRYPOINT ["terraform-compliance"]
