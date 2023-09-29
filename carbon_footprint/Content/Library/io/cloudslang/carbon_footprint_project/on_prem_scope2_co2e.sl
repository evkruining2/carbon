namespace: io.cloudslang.carbon_footprint_project
flow:
  name: on_prem_scope2_co2e
  inputs:
    - co2e_kwh_estimate: '0.408'
  workflow:
    - create_timestamp:
        do:
          io.cloudslang.carbon_footprint_project.tools.create_timestamp: []
        publish:
          - timestamp
        navigate:
          - SUCCESS: write_dc_scope2_co2e_to_odl
    - write_dc_scope2_co2e_to_odl:
        do:
          io.cloudslang.carbon_footprint_project.oneview.write_dc_scope2_co2e_to_odl:
            - timestamp: '${timestamp}'
            - co2e_kwh_estimate: '${co2e_kwh_estimate}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      create_timestamp:
        x: 80
        'y': 160
      write_dc_scope2_co2e_to_odl:
        x: 280
        'y': 160
        navigate:
          3ffdb8eb-de88-771d-bac3-1e2d36060cfa:
            targetId: 59a99246-3f95-a6db-64b5-923ab1a3e266
            port: SUCCESS
    results:
      SUCCESS:
        59a99246-3f95-a6db-64b5-923ab1a3e266:
          x: 560
          'y': 200

