namespace: io.cloudslang.carbon_footprint_project.aws
flow:
  name: main_aws_flow
  workflow:
    - create_timestamp_flow:
        do:
          io.cloudslang.carbon_footprint_project.tools.create_timestamp_flow: []
        publish:
          - timestamp
        navigate:
          - SUCCESS: get_topology
          - FAILURE: on_failure
    - get_topology:
        do:
          io.cloudslang.carbon_footprint_project.ucmdb.get_topology:
            - topology: DCOE_ESG_AWS
        publish:
          - ucmdbIds
        navigate:
          - SUCCESS: get_vm_details
          - FAILURE: on_failure
    - get_vm_details:
        do:
          io.cloudslang.carbon_footprint_project.aws.get_vm_details:
            - timestamp: '${timestamp}'
            - ucmdb_json: '${ucmdbIds}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      create_timestamp_flow:
        x: 80
        'y': 80
      get_topology:
        x: 280
        'y': 80
      get_vm_details:
        x: 480
        'y': 80
        navigate:
          45f91128-d7f5-4a7a-f041-03274f4addd7:
            targetId: 2c792f2b-0cc0-21c3-0417-685c3a120fd2
            port: SUCCESS
    results:
      SUCCESS:
        2c792f2b-0cc0-21c3-0417-685c3a120fd2:
          x: 480
          'y': 320
