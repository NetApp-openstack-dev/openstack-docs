Clustered Data ONTAP
--------------------

This section provides an example configuration script to be executed
within Data ONTAP that enables two SVMs, appropriately configured for
the Cinder configuration referenced in
the section called ":ref:`cinder-conf`". Note that you may
have to edit IP addresses and feature lists based on the environment and
licenses present.

::

    # create aggrs
    storage aggregate create -aggregate aggr1 -diskcount 24 -nodes \
    democluster-1-01

    storage aggregate create -aggregate aggr2 -diskcount 24 -nodes \
    democluster-1-02

    # create SVMs
    vserver create -vserver demo-iscsi-svm -rootvolume vol1 \
    -aggregate aggr1 -ns-switch file -rootvolume-security-style unix

    vserver create -vserver demo-nfs-svm -rootvolume vol1 \
    -aggregate aggr2 -ns-switch file -rootvolume-security-style unix

    # iSCSI setup
    iscsi create -vserver demo-iscsi-svm

    network interface create -vserver demo-iscsi-svm -lif \
    demo-iscsi-data -role data -data-protocol iscsi -home-node \
    democluster-1-01 -home-port e0d -address 10.63.40.149 \
     -netmask 255.255.192.0

    volume create -vserver demo-iscsi-svm -volume vol2 \
    -aggregate aggr1 -size 10g

    vserver export-policy rule create -vserver demo-iscsi-svm \
    -policyname default -clientmatch 0.0.0.0/0 -rorule any -rwrule \
    any -superuser any -anon 0

    volume create -vserver rcallawa-iscsi-vserver -volume vol1_plain \
    -aggregate aggr1 -size 10g

    # NFS setup
    nfs create -vserver demo-nfs-svm -access true
    network interface create -vserver demo-nfs-svm -lif demo-nfs-data \
    -role data -home-node democluster-1-02 -home-port e0d -address \
    10.63.40.153 -netmask 255.255.192.0

    vserver export-policy rule create -vserver demo-nfs-svm \
    -policyname default -clientmatch 0.0.0.0/0 -rorule any -rwrule \
    any -superuser any -anon 0

    volume create -vserver demo-nfs-svm -volume vol2_dedup -aggregate \
    aggr2 -size 6g -junction-path /vol2_dedup

    volume create -vserver demo-nfs-svm -volume vol3_compressed \
    -aggregate aggr2 -size 6g -junction-path /vol3_compressed

    volume create -vserver demo-nfs-svm -volume vol4_mirrored \
    -aggregate aggr2 -size 5g -junction-path /vol4_mirrored

    volume create -vserver demo-nfs-svm -volume vol4_mirror_dest \
    -aggregate aggr2 -size 5g -type DP

    volume create -vserver demo-nfs-svm -volume vol5_plain \
    -aggregate aggr2 -size 6g -junction-path /vol5_plain

    # SSC features
    volume efficiency on -vserver demo-nfs-svm -volume vol2_dedup

    volume efficiency on -vserver demo-nfs-svm -volume vol3_compressed

    volume efficiency modify -vserver demo-nfs-svm -volume \
    vol3_compressed -compression true -inline-compression true

    snapmirror create -source-path demo-nfs-svm:vol4_mirrored \
    -destination-path demo-nfs-svm:vol4_mirror_dest -type DP \
    -vserver demo-nfs-svm

    snapmirror initialize -source-path demo-nfs-svm:vol4_mirrored \
    -destination-path demo-nfs-svm:vol4_mirror_dest -type DP

    # enable v4.0, v4.1, pNFS
    nfs modify -vserver demo-nfs-svm -v4.0 enabled -v4.1 enabled \
    -v4.1-pnfs enabled


