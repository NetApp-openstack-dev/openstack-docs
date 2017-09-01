Setup ONTAP: With Share Server
==========================================

This section provides an example set of configuration commands to
be executed within ONTAP that enables one SVM appropriately
configured for the Manila configuration referenced in the section
called ":ref:`manila-conf-ex`". Note that you may have to edit IP
addresses and feature lists based on the environment and licenses
present.


Licenses
--------
    Assign licenses

    ::

        license add --license-code xxxxxxxxxxxxxx

        license add --license-code xxxxxxxxxxxxxx


Aggregates
----------
    Create aggrs

    ::

        storage aggregate create -aggregate aggr1 -diskcount 24 \
        -nodes cluster-1-01

        storage aggregate create -aggregate aggr2 -diskcount 24 \
        -nodes cluster-1-02
