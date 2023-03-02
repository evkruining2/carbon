namespace: io.cloudslang.carbon_footprint_project.ucmdb
flow:
  name: get_token
  inputs:
    - ucmdb_url: ucmdb.advantageinc.org
    - username
    - password:
        sensitive: true
    - trust_all_roots:
        default: 'true'
        required: false
    - x_509_hostname_verifier:
        default: allow_all
        required: false
  workflow:
    - get_authentication_token:
        do:
          io.cloudslang.microfocus.ucmdb.v1.authentication.get_authentication_token:
            - url: '${ucmdb_url}'
            - username: '${username}'
            - password:
                value: '${password}'
                sensitive: true
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
        publish:
          - token
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - token: '${token}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_authentication_token:
        x: 200
        'y': 120
        navigate:
          3901b535-d093-f4e8-b9aa-d218f9f3f77d:
            targetId: 916d89a3-1a40-7c65-5b24-d7ddf674354a
            port: SUCCESS
    results:
      SUCCESS:
        916d89a3-1a40-7c65-5b24-d7ddf674354a:
          x: 400
          'y': 160
