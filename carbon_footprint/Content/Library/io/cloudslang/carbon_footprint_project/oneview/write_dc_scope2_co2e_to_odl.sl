namespace: io.cloudslang.carbon_footprint_project.oneview
flow:
  name: write_dc_scope2_co2e_to_odl
  inputs:
    - timestamp
  workflow:
    - local_dc_co2e:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.local_dc_co2e:
            - timestamp: '${timestamp}'
        publish:
          - date_of_sample
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  outputs:
    - date_of_sample: '${date_of_sample}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      local_dc_co2e:
        x: 93
        'y': 85
        navigate:
          e78f9ee0-0df6-12f4-7556-2bc3695fe731:
            targetId: aa243003-4d3d-ce3a-1c71-bf1644cd54fe
            port: SUCCESS
    results:
      SUCCESS:
        aa243003-4d3d-ce3a-1c71-bf1644cd54fe:
          x: 307
          'y': 88

