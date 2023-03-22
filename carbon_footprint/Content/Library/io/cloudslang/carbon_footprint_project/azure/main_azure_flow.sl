namespace: io.cloudslang.carbon_footprint_project.azure
flow:
  name: main_azure_flow
  workflow:
    - create_timestamp_flow:
        do:
          io.cloudslang.carbon_footprint_project.tools.create_timestamp_flow: []
        publish:
          - timestamp
        navigate:
          - SUCCESS: get_ucmdbid_azure_vm_name
          - FAILURE: on_failure
    - get_ucmdbid_azure_vm_name:
        do:
          io.cloudslang.carbon_footprint_project.ucmdb.get_ucmdbid_azure_vm_name: []
        publish:
          - ucmdbids
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_vm_details
    - get_vm_details:
        do:
          io.cloudslang.carbon_footprint_project.azure.get_vm_details:
            - ucmdbids: '${ucmdbids}'
            - timestamp: '${timestamp}'
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
        x: 65
        'y': 72
      get_ucmdbid_azure_vm_name:
        x: 244
        'y': 80
      get_vm_details:
        x: 464
        'y': 87
        navigate:
          70702799-dc36-a8ad-27a6-e4910dd93e19:
            targetId: 76fdb7f8-5736-30e5-1e40-0a60056a7d6f
            port: SUCCESS
    results:
      SUCCESS:
        76fdb7f8-5736-30e5-1e40-0a60056a7d6f:
          x: 468
          'y': 285

