namespace: io.cloudslang.carbon_footprint_project.test
flow:
  name: append
  inputs:
    - providers: 'aws,gcp,azure'
  workflow:
    - batch_processing_cpu:
        parallel_loop:
          for: provider in providers
          do:
            io.cloudslang.carbon_footprint_project.test.batch_processing_cpu:
              - provider: '${provider}'
        publish:
          - co2e_results_0: '${str(branches_context[0]["co2e_results"])}'
          - co2e_results_1: '${str(branches_context[1]["co2e_results"])}'
          - co2e_results_2: '${str(branches_context[2]["co2e_results"])}'
        navigate:
          - FAILURE: on_failure
          - SUCCESS: SUCCESS
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      batch_processing_cpu:
        x: 200
        'y': 120
        navigate:
          653decf4-2f10-895e-c27d-ec043178d942:
            targetId: 5aba9338-236f-42ec-1eaf-6488b3b393cc
            port: SUCCESS
    results:
      SUCCESS:
        5aba9338-236f-42ec-1eaf-6488b3b393cc:
          x: 440
          'y': 160
