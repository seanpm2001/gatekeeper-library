package k8sautomountserviceaccounttoken

violation[{"msg": msg}] {
    obj := input.review.object
    mountServiceAccountToken(obj.spec)
    msg := sprintf("Automounting service account token is disallowed, pod: %v", [obj.metadata.name])
}

mountServiceAccountToken(spec) {
    spec.automountServiceAccountToken == true
}

# if there is no automountServiceAccountToken spec, check on volumeMount in containers. Service Account token is mounted on /var/run/secrets/kubernetes.io/serviceaccount
# https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/#serviceaccount-admission-controller
mountServiceAccountToken(spec) {
    not has_key(spec, "automountServiceAccountToken")
    "/var/run/secrets/kubernetes.io/serviceaccount" == input_containers[_].volumeMounts[_].mountPath
}

input_containers[c] {
    c := input.review.object.spec.containers[_]
}

input_containers[c] {
    c := input.review.object.spec.initContainers[_]
}

has_key(x, k) {
    _ = x[k]
}
