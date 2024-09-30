# Bootstrap and join cluster
/etc/eks/bootstrap.sh '${cluster_id}' --b64-cluster-ca '${cluster_certificate_authority_b64}' --apiserver-endpoint '${apiserver_endpoint}'