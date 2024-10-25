MIME-version: 1.0
Content-Type: multipart-mixed; boundary="BOUNDARY"

--BOUNDARY
Content-Type: application/node.eks.aws

---
apiVersion: node.eks.aws/v1alpha1
kind: NodeConfig
spec:
  cluster:
    name: ${cluster_id}
    apiServerEndpoint: ${apiserver_endpoint}
    certificateAuthority: ${cluster_certificate_authority_b64}
    cidr: ${eks_cidr}

--BOUNDARY
Content-Type application/kubelet.config.k8s.io

---
apiVersion: kubelet.config.k8s.io.v1beta1
kind: KubeletConfiguration
address: 0.0.0.0
authentication:
    anonymous:
        enabled: false
    webhook:
        cacheTTL: 2m0s
        enabled: true
    x509:
        clientCAFile: /etc/kubernetes/pki/ca.crt
authorization:
    mode: Webhook 
    webhook:
        cacheAuthorizedTTL: 5m0s
        cacheUnauthorizedTTL: 30s
clusterDomain: cluster.local
hairpinMode: hairpin-veth
readOnlyPort: 0
cgroupDriver: cgroupfs
cgroupRoot: /
featureGates:
    RotateKubeletServerCertificate: true
protectKernelDefaults: true
serializeImagePulls: false
serverTLSBootstrap: true
streamingConnectionIdleTimeout: 4h0m0s
makeIPTablesUtilChains: true
eventRecordQPS: 5
rotateCertificates: true
tlsCipherSuites:
    - TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
    - TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
    - TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305
    - TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
    - TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305
    - TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
    - TLS_RSA_WITH_AES_256_GCM_SHA384
    - TLS_RSA_WITH_AES_128_GCM_SHA256 

--BOUNDARY
Content-Type: text/x-shellscript; charset="us-ascii"
# Custom bash code for your specific use case goes here
#!/bin/bash
  set -o xtrace
  
  # yum updates
  sudo yum update

--BOUNDARY--
