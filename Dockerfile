FROM quay.io/eduk8s/base-environment:210414.121557.03f0085 as tanzu-tools

USER root

RUN mkdir /opt/tanzu && \
    chown 1001:0 /opt/tanzu

COPY --chown=1001:0 package.json /opt/tanzu/

USER 1001

WORKDIR /opt/tanzu

ARG VMWUSER=username
ARG VMWPASS=password

RUN npm install && \
    mkdir /opt/tanzu/bin && \
    ln -s /opt/tanzu/node_modules/.bin/vmw-cli /opt/tanzu/bin/vmw-cli

ENV PATH=/opt/tanzu/bin:$PATH

RUN vmw-cli ls vmware_tanzu_kubernetes_grid/1_x/PRODUCT_BINARY && \
    vmw-cli cp tanzu-cli-bundle-linux-amd64.tar

RUN tar xvf tanzu-cli-bundle-linux-amd64.tar && \
    rm tanzu-cli-bundle-linux-amd64.tar && \
    cp /opt/tanzu/cli/core/v1.3.0/tanzu-core-linux_amd64 /opt/tanzu/bin/tanzu

RUN tanzu plugin clean && \
    tanzu plugin install --local cli all && \
    tanzu plugin list

RUN rm -rf cli

FROM quay.io/eduk8s/base-environment:210414.121557.03f0085

COPY --from=tanzu-tools --chown=1001:0 /opt/tanzu /opt/tanzu
COPY --from=tanzu-tools --chown=1001:0 /home/eduk8s /home/eduk8s

COPY --chown=1001:0 profile /opt/eduk8s/workshop/profile

ENV PATH=/opt/tanzu/bin:$PATH
