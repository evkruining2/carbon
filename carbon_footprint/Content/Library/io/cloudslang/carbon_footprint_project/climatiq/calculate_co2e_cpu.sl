########################################################################################################################
#!!
#! @input provider: aws or azure
#! @input cpu_count: amount of cpu's
#!!#
########################################################################################################################
namespace: io.cloudslang.carbon_footprint_project.climatiq
flow:
  name: calculate_co2e_cpu
  inputs:
    - climatiq_url: 'https://beta3.api.climatiq.io'
    - climatiq_token: Y3Q5BATS8TM2ARKBB18Y8MN95HX1
    - provider: aws
    - region: eu_west_1
    - cpu_count: '24'
    - cpu_load: '88'
    - proxy_host:
        default: 10.0.0.1
        required: false
    - proxy_port:
        default: '3128'
        required: false
    - trust_all_roots:
        default: 'true'
        required: false
    - hostname_verifier:
        default: allow_all
        required: false
  workflow:
    - climatiq_io_get_cpu:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: "${climatiq_url+'/compute/'+provider+'/cpu'}"
            - proxy_host: '${proxy_host}'
            - proxy_port: '${proxy_port}'
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${hostname_verifier}'
            - headers: "${'Authorization: Bearer '+climatiq_token}"
            - body: "${'{'+\\\n'\"cpu_count\": '+cpu_count+','+\\\n'\"region\": \"'+region+'\",'+\\\n'\"cpu_load\": '+cpu_load+','+\\\n'\"duration\": 24,'+\\\n'\"duration_unit\": \"h\"'+\\\n'}'}"
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: json_path_extract_co2e
          - FAILURE: on_failure
    - json_path_extract_co2e:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: $.co2e
        publish:
          - co2e: '${return_result}'
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - co2e: '${co2e}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      climatiq_io_get_cpu:
        x: 80
        'y': 80
      json_path_extract_co2e:
        x: 280
        'y': 80
        navigate:
          bc1c16a8-9698-c49e-f025-5b5febbe9128:
            targetId: 9cf1a507-2d60-db49-5d3c-a6c78597df86
            port: SUCCESS
    results:
      SUCCESS:
        9cf1a507-2d60-db49-5d3c-a6c78597df86:
          x: 480
          'y': 80
