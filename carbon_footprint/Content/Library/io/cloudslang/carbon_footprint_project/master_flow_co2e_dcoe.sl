namespace: io.cloudslang.carbon_footprint_project
flow:
  name: master_flow_co2e_dcoe
  workflow:
    - create_timestamp_flow:
        worker_group:
          value: RAS_Operator_Path
          override: true
        do:
          io.cloudslang.carbon_footprint_project.tools.create_timestamp_flow: []
        publish:
          - timestamp
        navigate:
          - SUCCESS: write_dc_scope2_co2e_to_odl
          - FAILURE: on_failure
    - write_dc_scope2_co2e_to_odl:
        worker_group:
          value: RAS_Operator_Path
          override: true
        do:
          io.cloudslang.carbon_footprint_project.oneview.write_dc_scope2_co2e_to_odl:
            - timestamp: '${timestamp}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: main_azure_flow
    - main_azure_flow:
        worker_group:
          value: RAS_Operator_Path
          override: true
        do:
          io.cloudslang.carbon_footprint_project.azure.main_azure_flow:
            - timestamp: '${timestamp}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: main_aws_flow
    - main_aws_flow:
        worker_group:
          value: RAS_Operator_Path
          override: true
        do:
          io.cloudslang.carbon_footprint_project.aws.main_aws_flow:
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
        x: 69
        'y': 87
      write_dc_scope2_co2e_to_odl:
        x: 260
        'y': 86
      main_azure_flow:
        x: 446
        'y': 87
      main_aws_flow:
        x: 618
        'y': 92
        navigate:
          7fde62fc-7ff6-fdf6-c8c6-f3dd05ec8787:
            targetId: a7328fff-080d-5415-2f87-e0a2893444be
            port: SUCCESS
    results:
      SUCCESS:
        a7328fff-080d-5415-2f87-e0a2893444be:
          x: 615
          'y': 319

