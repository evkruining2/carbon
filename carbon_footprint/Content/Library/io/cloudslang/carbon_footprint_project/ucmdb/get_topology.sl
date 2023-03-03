namespace: io.cloudslang.carbon_footprint_project.ucmdb
flow:
  name: get_topology
  inputs:
    - ucmdb_api: 'https://smax-admin.advantageinc.org:3443/ucmdb-server/rest-api/topology'
    - topology: Servers Card
  workflow:
    - get_token:
        do:
          io.cloudslang.carbon_footprint_project.ucmdb.get_token: []
        publish:
          - token
        navigate:
          - SUCCESS: http_client_get
          - FAILURE: on_failure
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: '${ucmdb_api}'
            - headers: "${'Authorization: Bearer '+token}"
            - query_params: '${topology}'
            - content_type: application/json
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: json_path_query
          - FAILURE: on_failure
    - json_path_query:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: '$..cis[?(@.type="vmware_esx_server")].ucmdbId'
        publish:
          - ucmdbIds: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - ucmdbIds: '${ucmdbIds}'
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      http_client_get:
        x: 360
        'y': 80
      get_token:
        x: 120
        'y': 80
      json_path_query:
        x: 600
        'y': 80
        navigate:
          6106ae5e-c5e5-44ca-491b-faceb143e8d0:
            targetId: ff7282ef-2d07-0b54-afcc-e1c141e7cb02
            port: SUCCESS
    results:
      SUCCESS:
        ff7282ef-2d07-0b54-afcc-e1c141e7cb02:
          x: 600
          'y': 320
