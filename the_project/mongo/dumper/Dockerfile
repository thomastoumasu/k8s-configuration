FROM mongo
WORKDIR /usr/src/app
COPY --chmod=755 dumper.sh ./
ARG KEY
ENV KEY=${KEY}
# COPY --chmod=555 private-key.json ./
USER root
RUN apt-get update && \
    apt-get install -y curl gnupg && \
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg  add - && \
    apt-get update -y && \
    apt-get install google-cloud-sdk -y
ENTRYPOINT ["./dumper.sh"]
CMD ["mongodb://the_username:the_password@mongo-svc.project:27017/the_database", "thomastoumasu_k8s-bucket"]