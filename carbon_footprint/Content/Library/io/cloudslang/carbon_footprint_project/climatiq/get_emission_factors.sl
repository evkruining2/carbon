########################################################################################################################
#!!
#! @description: This flow will query Climatq.io for the emission factors from a given location/provider, using a unique UUID. To lookup the appropriate UUID, go to the data explorer here: https://www.climatiq.io/explorer
#!!#
########################################################################################################################
namespace: io.cloudslang.carbon_footprint_project.climatiq
flow:
  name: get_emission_factors
  inputs:
    - climatiq_url: 'https://beta4.api.climatiq.io'
    - climatiq_token: Y3Q5BATS8TM2ARKBB18Y8MN95HX1
    - provider_uuid: 0bd33651-72bd-4b1d-ad84-8cacaf574b5e
    - activity_id: electricity-supply_grid-source_supplier_mix
    - data_version: '5.5'
  workflow:
    - get_climatiq_io_provider_emission_factor:
        worker_group:
          value: "${get_sp('io.cloudslang.carbon_footprint_project.worker_group')}"
          override: true
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${climatiq_url+'/estimate'}"
            - proxy_host: "${get_sp('io.cloudslang.carbon_footprint_project.proxy_host')}"
            - proxy_port: "${get_sp('io.cloudslang.carbon_footprint_project.proxy_port')}"
            - headers: "${'Authorization: Bearer '+climatiq_token}"
            - body: "${'{'+\\\n'\"emission_factor\": {'+\\\n'\"activity_id\": \"'+activity_id+'\",'+\\\n'\"data_version\": \"'+data_version+'\"},'+\\\n'\"parameters\": {'+\\\n'\"energy\": 1,'+\\\n'\"energy_unit\": \"kWh\"'+\\\n'}}'}"
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: json_path_query
          - FAILURE: on_failure
    - json_path_query:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: $.co2e
        publish:
          - co2e_kwh: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - co2e_kwh: '${co2e_kwh}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_climatiq_io_provider_emission_factor:
        x: 74
        'y': 96
      json_path_query:
        x: 143
        'y': 261
        navigate:
          e4ee4e5c-00eb-a08f-3420-73aec9bad093:
            targetId: 80d43498-370b-fc7c-6abf-e015e4d2314f
            port: SUCCESS
    results:
      SUCCESS:
        80d43498-370b-fc7c-6abf-e015e4d2314f:
          x: 221
          'y': 90

