namespace: io.cloudslang.carbon_footprint_project.climatiq
flow:
  name: azure_vm_instance
  inputs:
    - provider: azure
    - region
    - cpu_count
    - memory
  workflow:
    - calculate_co2e_cpu:
        do:
          io.cloudslang.carbon_footprint_project.climatiq.calculate_co2e_cpu:
            - provider: '${provider}'
            - region: '${region}'
            - cpu_count: '${cpu_count}'
        publish:
          - co2e
          - total_co2e: '0'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: add_numbers
    - calculate_co2e_memory:
        do:
          io.cloudslang.carbon_footprint_project.climatiq.calculate_co2e_memory:
            - provider: '${provider}'
            - region: '${region}'
            - memory: '${memory}'
            - data_unit: MB
        publish:
          - co2e
        navigate:
          - FAILURE: on_failure
          - SUCCESS: add_numbers_1
    - add_numbers:
        do:
          io.cloudslang.base.math.add_numbers:
            - value1: '${total_co2e}'
            - value2: '${co2e}'
        publish:
          - total_co2e: '${result}'
        navigate:
          - SUCCESS: calculate_co2e_memory
          - FAILURE: on_failure
    - add_numbers_1:
        do:
          io.cloudslang.base.math.add_numbers:
            - value1: '${total_co2e}'
            - value2: '${co2e}'
        publish:
          - total_co2e: '${result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - total_co2e: '${total_co2e}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      calculate_co2e_cpu:
        x: 120
        'y': 80
      calculate_co2e_memory:
        x: 360
        'y': 80
      add_numbers:
        x: 240
        'y': 280
      add_numbers_1:
        x: 520
        'y': 280
        navigate:
          f6166e2d-d29b-4bd8-02ee-cb0a447f37e9:
            targetId: 86ef6df4-a299-8026-ab07-c27c49b8adb4
            port: SUCCESS
    results:
      SUCCESS:
        86ef6df4-a299-8026-ab07-c27c49b8adb4:
          x: 680
          'y': 80
