namespace: io.cloudslang.carbon_footprint_project.oneview
flow:
  name: get_server_average_power
  inputs:
    - oneview_url: 'https://synergy.advantageinc.org'
    - server_uuid: 31323250-3933-4753-4832-333554543632
  workflow:
    - get_oneview_token:
        do:
          io.cloudslang.carbon_footprint_project.oneview.get_oneview_token: []
        publish:
          - token
        navigate:
          - FAILURE: on_failure
          - SUCCESS: http_client_get
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${oneview_url+'/rest/server-hardware/'+server_uuid+'/utilization?fields=AveragePower&view=native'}"
            - trust_all_roots: 'true'
            - x_509_hostname_verifier: allow_all
            - headers: "${'Auth: '+token}"
            - content_type: application/json
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: get_latest_sample
          - FAILURE: on_failure
    - get_latest_sample:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: '$.metricList..metricSamples[0]'
        publish:
          - power_consumption: "${return_result.partition(',')[2].strip(']')}"
          - epoch: "${return_result.partition(',')[0].strip('[')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - current_power_consumption: '${power_consumption}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_oneview_token:
        x: 86
        'y': 100
      http_client_get:
        x: 274
        'y': 102
      get_latest_sample:
        x: 270
        'y': 311
        navigate:
          9fba90c6-a3f0-2dd8-95e5-ae184a238e3e:
            targetId: 3f7b896c-acf5-b665-7590-37502c8985a6
            port: SUCCESS
    results:
      SUCCESS:
        3f7b896c-acf5-b665-7590-37502c8985a6:
          x: 450
          'y': 105

