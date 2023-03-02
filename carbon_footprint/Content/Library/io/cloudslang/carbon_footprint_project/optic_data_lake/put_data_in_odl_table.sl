namespace: io.cloudslang.carbon_footprint_project.optic_data_lake
flow:
  name: put_data_in_odl_table
  inputs:
    - odl_host: odl.advantageinc.org
    - x509_verifier: allow_all
    - trust_all_roots: 'true'
  workflow:
    - http_client_put:
        do:
          io.cloudslang.base.http.http_client_put:
            - url: '${odl_host}'
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x509_verifier}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      http_client_put:
        x: 160
        'y': 200
        navigate:
          e3ea9015-19d3-921c-fc7b-e3624593470c:
            targetId: 34c849c6-d627-a903-2e00-65489f817dc8
            port: SUCCESS
    results:
      SUCCESS:
        34c849c6-d627-a903-2e00-65489f817dc8:
          x: 440
          'y': 200
