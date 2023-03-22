namespace: io.cloudslang.carbon_footprint_project.aws
flow:
  name: get_vm_details
  inputs:
    - timestamp
    - ucmdb_json
  workflow:
    - json_path_query:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${ucmdb_json}'
            - json_path: $.cis
        publish:
          - return_result
        navigate:
          - SUCCESS: array_iterator
          - FAILURE: on_failure
    - array_iterator:
        do:
          io.cloudslang.base.json.array_iterator:
            - array: '${return_result}'
        publish:
          - json_iterator: '${result_string}'
        navigate:
          - HAS_MORE: get_region
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - get_ucmdbid:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_iterator}'
            - json_path: $.ucmdbId
        publish:
          - ucmdbid: "${return_result.strip('\"')}"
        navigate:
          - SUCCESS: get_global_id
          - FAILURE: on_failure
    - get_global_id:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_iterator}'
            - json_path: $.globalId
        publish:
          - globalid: "${return_result.strip('\"')}"
        navigate:
          - SUCCESS: get_primary_dns_name
          - FAILURE: on_failure
    - get_primary_dns_name:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_iterator}'
            - json_path: $.properties.primary_dns_name
        publish:
          - dns: "${return_result.strip('\"')}"
        navigate:
          - SUCCESS: clean_up_ip_address
          - FAILURE: on_failure
    - get_display_label:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_iterator}'
            - json_path: $.properties.display_label
        publish:
          - label: "${return_result.strip('\"')}"
        navigate:
          - SUCCESS: get_ucmdbid
          - FAILURE: on_failure
    - get_region:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_iterator}'
            - json_path: $.properties.region
        publish:
          - region: "${cs_replace(return_result,\"-\",\"_\",).strip('\"')}"
        navigate:
          - SUCCESS: get_node_model
          - FAILURE: array_iterator
    - get_node_model:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_iterator}'
            - json_path: $.properties.node_model
        publish:
          - model: "${return_result.strip('\"')}"
        navigate:
          - SUCCESS: get_display_label
          - FAILURE: array_iterator
    - aws_vm_instance:
        do:
          io.cloudslang.carbon_footprint_project.climatiq.aws_vm_instance:
            - region: '${region}'
            - instance: '${model}'
        publish:
          - total_co2e
        navigate:
          - FAILURE: on_failure
          - SUCCESS: odl_load_data
    - strip_last_char_from_region:
        do:
          io.cloudslang.base.utils.do_nothing:
            - dirty_region: '${region}'
        publish:
          - region: '${dirty_region[:-1]}'
        navigate:
          - SUCCESS: aws_vm_instance
          - FAILURE: on_failure
    - odl_load_data:
        do:
          io.cloudslang.carbon_footprint_project.optic_data_lake.odl_load_data:
            - timestamp: '${timestamp}'
            - scope2_co2e: '0'
            - scope3_co2e: '${total_co2e}'
            - powerusage: '0'
            - cmdb_id: '${ucmdbid}'
            - cmdb_global_id: '${globalid}'
            - node_fqdn: '${dns}'
            - node_ip_address: '${dns}'
            - cloudvendor: AWS
            - cloudregion: '${region}'
        navigate:
          - SUCCESS: array_iterator
          - FAILURE: on_failure
    - clean_up_ip_address:
        do:
          io.cloudslang.base.strings.remove:
            - origin_string: '${dns}'
            - text: ip-
        publish:
          - ip_address: "${cs_replace(new_string.split('.')[0],\"-\",\".\",)}"
        navigate:
          - SUCCESS: strip_last_char_from_region
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      strip_last_char_from_region:
        x: 400
        'y': 440
      json_path_query:
        x: 40
        'y': 80
      get_primary_dns_name:
        x: 200
        'y': 600
      clean_up_ip_address:
        x: 200
        'y': 440
      get_display_label:
        x: 40
        'y': 280
      get_global_id:
        x: 40
        'y': 600
      get_ucmdbid:
        x: 40
        'y': 440
      array_iterator:
        x: 280
        'y': 80
        navigate:
          58ec90b4-f0d3-3682-c9c6-e42818d0f35a:
            targetId: 2e9ad66a-d39c-f331-5655-f51850c74aca
            port: NO_MORE
      get_node_model:
        x: 200
        'y': 280
      odl_load_data:
        x: 560
        'y': 280
      aws_vm_instance:
        x: 560
        'y': 440
      get_region:
        x: 400
        'y': 280
    results:
      SUCCESS:
        2e9ad66a-d39c-f331-5655-f51850c74aca:
          x: 600
          'y': 80
