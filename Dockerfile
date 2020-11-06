FROM python:3.7.3-slim

ARG VERSION=1.3.6
ARG TARGET_ARCH='linux_amd64'

LABEL terraform_compliance.version="${VERSION}"
LABEL author="Emre Erkunt <emre.erkunt@gmail.com>"
LABEL source="https://github.com/eerkunt/terraform-compliance"

ENV TERRAFORM_VERSION=0.12.24
ENV TARGET_ARCH="${TARGET_ARCH}"
ENV HASHICORP_PGP_KEY="${HASHICORP_PGP_KEY}"

RUN  set -ex 
     RUN BUILD_DEPS='wget unzip gpg' 
     RUN RUN_DEPS='git' 
     RUN apt-get update 
     RUN apt-get install -y ${BUILD_DEPS} ${RUN_DEPS} 
     RUN TERRAFORM_FILE_NAME="terraform_${TERRAFORM_VERSION}_${TARGET_ARCH}.zip" 
     RUN SHA256SUM_FILE_NAME="terraform_${TERRAFORM_VERSION}_SHA256SUMS" 
     RUN SHA256SUM_SIG_FILE_NAME="terraform_${TERRAFORM_VERSION}_SHA256SUMS.sig" 
     RUN SHA256SUM_FILE_NAME_FOR_ARCH="${SHA256SUM_FILE_NAME}.${TARGET_ARCH}" 
     RUN HASHICORP_PGP_KEY_FILE='hashicorp-pgp-key.pub' 
     RUN OLD_BASEDIR="$(pwd)" 
     RUN TMP_DIR=$(mktemp -d) 
     RUN cd "${TMP_DIR}" 
     COPY hashicorp-pgp-key.pub "${HASHICORP_PGP_KEY_FILE}"
     RUN echo "${HASHICORP_PGP_KEY}" > "${HASHICORP_PGP_KEY_FILE}" 
     RUN wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${SHA256SUM_FILE_NAME}" 
     RUN wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${SHA256SUM_SIG_FILE_NAME}" 
     RUN gpg --import "${HASHICORP_PGP_KEY_FILE}" 
     RUN gpg --verify "${SHA256SUM_SIG_FILE_NAME}" "${SHA256SUM_FILE_NAME}" 
     RUN wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_FILE_NAME}" 
     RUN grep "${TERRAFORM_FILE_NAME}" "${SHA256SUM_FILE_NAME}" > "${SHA256SUM_FILE_NAME_FOR_ARCH}" 
     RUN ls -al . 
     RUN sha256sum -c "${SHA256SUM_FILE_NAME_FOR_ARCH}" 
     RUN unzip "${TERRAFORM_FILE_NAME}" 
     RUN install terraform /usr/bin/ 
     RUN cd "${OLD_BASEDIR}" 
     RUN unset OLD_BASEDIR 
     RUN rm -vrf ${TMP_DIR} 
     RUN pip install --upgrade pip 
     RUN pip install terraform-compliance=="${VERSION}" 
     RUN pip uninstall -y radish radish-bdd 
     RUN pip install radish radish-bdd 
     RUN pip install checkov 
     RUN apt-get remove -y ${BUILD_DEPS} 
     RUN apt-get autoremove -y 
     RUN apt-get clean -y 
     RUN rm -rf /var/lib/apt/lists/* 
     RUN mkdir -p /target

WORKDIR /target
ENTRYPOINT ["terraform-compliance"]
