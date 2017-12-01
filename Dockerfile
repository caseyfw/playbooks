FROM alpine
RUN apk --update add python py2-pip openssh openssl ca-certificates \
&& apk --update add --virtual build-dependencies python-dev libffi-dev openssl-dev build-base \
&& pip install --upgrade pip cffi \
&& pip install ansible dnspython boto \
&& apk del build-dependencies \
&& rm -rf /var/cache/apk/*

WORKDIR /code

ENTRYPOINT ["/bin/sh"]
