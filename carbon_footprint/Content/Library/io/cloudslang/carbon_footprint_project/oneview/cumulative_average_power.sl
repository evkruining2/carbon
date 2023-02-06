namespace: io.cloudslang.carbon_footprint_project.oneview
flow:
  name: cumulative_average_power
  inputs:
    - list_of_servers: 'esx01.advantageinc.org,esx02.advantageinc.org,esx03.advantageinc.org'
    - trust_all_roots:
        default: 'true'
        required: false
    - x_509_hostname_verifier:
        default: allow_all
        required: false
  workflow:
    - get_oneview_token_1:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.get_oneview_token:
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
        publish:
          - token
        navigate:
          - FAILURE: on_failure
          - SUCCESS: list_iterator
    - list_iterator:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${list_of_servers}'
        publish:
          - serverName: '${result_string}'
        navigate:
          - HAS_MORE: get_server_uuid_from_name
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - add_numbers:
        do:
          io.cloudslang.base.math.add_numbers:
            - value1: '${number}'
            - value2: '${current_power_consumption}'
        publish:
          - number: '${result}'
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - get_server_uuid_from_name:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.get_server_uuid_from_name:
            - token: '${token}'
            - serverName: '${serverName}'
        publish:
          - uuid
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_server_average_power
    - get_server_average_power:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.get_server_average_power:
            - server_uuid: '${uuid}'
            - token: '${token}'
        publish:
          - current_power_consumption
          - date_of_sample
        navigate:
          - FAILURE: on_failure
          - SUCCESS: add_numbers
  outputs:
    - combined_power_consumption: '${number}'
    - servers: '${list_of_servers}'
    - date_of_sample: '${date_of_sample}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_oneview_token_1:
        x: 80
        'y': 80
      add_numbers:
        x: 280
        'y': 400
      get_server_uuid_from_name:
        x: 80
        'y': 240
      list_iterator:
        x: 280
        'y': 200
        navigate:
          435965e4-4647-bb84-9936-6c534305479c:
            targetId: d6a78080-cfa1-c39e-0c31-318fe0db4606
            port: NO_MORE
      get_server_average_power:
        x: 80
        'y': 440
    results:
      SUCCESS:
        d6a78080-cfa1-c39e-0c31-318fe0db4606:
          x: 520
          'y': 160
