FROM gcr.io/distroless/static:nonroot

COPY ./out/app /bin/kube-resource-explorer

ENTRYPOINT [ "kube-resource-explorer" ]
