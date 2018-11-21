FROM alpine:3.8

RUN apk add --no-cache make bash gawk git gnupg

ARG GIT_SECRET_VERSION=0.2.3
RUN wget https://github.com/sobolevn/git-secret/archive/v${GIT_SECRET_VERSION}.zip \
    && unzip -q v${GIT_SECRET_VERSION}.zip \
    && cd git-secret-${GIT_SECRET_VERSION} \
    && make build \
    && PREFIX="/usr/local" make install \
    && cd .. \
    && rm -rf git-secret-${GIT_SECRET_VERSION}

COPY private.key .
RUN gpg --batch --import private.key

WORKDIR /usr/repo

CMD [ "git", "secret", "list" ]