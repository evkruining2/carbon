########################################################################################################################
#!!
#! @output servers: List of queried servers
#! @output date_of_sample: Sample date
#! @output co2e_kwh: CO2e per kwh for provider
#!!#
########################################################################################################################
namespace: io.cloudslang.carbon_footprint_project.oneview.subflows
flow:
  name: local_dc_co2e
  inputs:
    - trust_all_roots:
        default: 'true'
        required: false
    - x_509_hostname_verifier:
        default: allow_all
        required: false
    - cmdb_global_id: 'null'
    - cmdb_id: 'null'
    - timestamp
  workflow:
    - get_server_names:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.get_server_names: []
        publish:
          - list_of_servers: '${server_names}'
          - token
          - number: '0'
          - csv: |
              timestamp,co2e,powerUsage,cmdb_id,cmdb_global_id,node_fqdn,node_ip
        navigate:
          - FAILURE: on_failure
          - SUCCESS: get_emission_factors
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
          - epoch
        navigate:
          - FAILURE: on_failure
          - SUCCESS: lookup_ip_address
    - get_emission_factors:
        do:
          io.cloudslang.carbon_footprint_project.climatiq.get_emission_factors: []
        publish:
          - co2e_kwh
        navigate:
          - FAILURE: on_failure
          - SUCCESS: list_iterator
    - co2e_per_hour:
        do:
          io.cloudslang.base.math.multiply_numbers:
            - value1: '${co2e_kwh}'
            - value2: '${number}'
        publish:
          - number: '${result}'
        navigate:
          - SUCCESS: co2e_per_24hr
    - watts_to_kwh:
        do:
          io.cloudslang.base.math.divide_numbers:
            - value1: '${current_power_consumption}'
            - value2: '1000'
        publish:
          - number: '${result}'
          - kwh: '${result}'
        navigate:
          - ILLEGAL: FAILURE
          - SUCCESS: kwh_per_24hr
    - co2e_per_24hr:
        do:
          io.cloudslang.base.math.multiply_numbers:
            - value1: '${number}'
            - value2: '24'
        publish:
          - co2e: '${result}'
        navigate:
          - SUCCESS: construct_csv
    - construct_csv:
        do:
          io.cloudslang.base.strings.append:
            - origin_string: '${csv}'
            - text: "${timestamp+','+co2e+','+kw24h+','+cmdb_id+','+cmdb_global_id+','+serverName+','+ip_address+'\\r\\n'}"
        publish:
          - csv: "${cs_replace(new_string,'null','',)}"
        navigate:
          - SUCCESS: list_iterator
    - lookup_ip_address:
        do:
          io.cloudslang.carbon_footprint_project.oneview.subflows.lookup_ip_address:
            - hostname: '${serverName}'
        publish:
          - ip_address
        navigate:
          - SUCCESS: watts_to_kwh
    - kwh_per_24hr:
        do:
          io.cloudslang.base.math.multiply_numbers:
            - value1: '${kwh}'
            - value2: '24'
        publish:
          - kw24h: '${result}'
        navigate:
          - SUCCESS: co2e_per_hour
  outputs:
    - servers: '${list_of_servers}'
    - date_of_sample: '${date_of_sample}'
    - co2e_kwh: '${co2e_kwh}'
    - csv: '${csv}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      lookup_ip_address:
        x: 47
        'y': 397
      co2e_per_hour:
        x: 608
        'y': 392
      co2e_per_24hr:
        x: 612
        'y': 214
      watts_to_kwh:
        x: 218
        'y': 398
        navigate:
          f5dcd00b-a861-83e7-bd7d-b7fd08d2dea9:
            targetId: 2c11562d-9351-b40b-d55e-e83262175e70
            port: ILLEGAL
      get_server_uuid_from_name:
        x: 215
        'y': 213
      list_iterator:
        x: 415
        'y': 57
        navigate:
          c077462c-5b33-fb76-0b4f-5cfe939212be:
            targetId: d6a78080-cfa1-c39e-0c31-318fe0db4606
            port: NO_MORE
      get_server_average_power:
        x: 43
        'y': 210
      kwh_per_24hr:
        x: 414
        'y': 394
      get_emission_factors:
        x: 214
        'y': 55
      get_server_names:
        x: 48
        'y': 60
      construct_csv:
        x: 413
        'y': 214
    results:
      FAILURE:
        2c11562d-9351-b40b-d55e-e83262175e70:
          x: 324
          'y': 525
      SUCCESS:
        d6a78080-cfa1-c39e-0c31-318fe0db4606:
          x: 613
          'y': 60