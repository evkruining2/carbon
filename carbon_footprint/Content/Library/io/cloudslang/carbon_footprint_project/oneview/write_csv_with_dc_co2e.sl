namespace: io.cloudslang.carbon_footprint_project.oneview
flow:
  name: write_csv_with_dc_co2e
  inputs:
    - file_path
  workflow:
    - create_timestamp_flow:
        do:
          io.cloudslang.carbon_footprint_project.tools.create_timestamp_flow: []
        publish:
          - timestamp
        navigate:
          - SUCCESS: local_dc_co2e
          - FAILURE: on_failure
    - local_dc_co2e:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.local_dc_co2e:
            - timestamp: '${timestamp}'
        publish:
          - csv
          - date_of_sample
        navigate:
          - FAILURE: on_failure
          - SUCCESS: write_to_file
    - write_to_file:
        do:
          io.cloudslang.base.filesystem.write_to_file:
            - file_path: '${file_path}'
            - text: '${csv}'
        publish:
          - message
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - date_of_sample: '${date_of_sample}'
    - csv: '${csv}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      local_dc_co2e:
        x: 80
        'y': 78
      write_to_file:
        x: 276
        'y': 74
        navigate:
          9ae852d8-ccee-7d5c-229c-fca48647f554:
            targetId: aa243003-4d3d-ce3a-1c71-bf1644cd54fe
            port: SUCCESS
      create_timestamp_flow:
        x: 80
        'y': 280
    results:
      SUCCESS:
        aa243003-4d3d-ce3a-1c71-bf1644cd54fe:
          x: 448
          'y': 78
