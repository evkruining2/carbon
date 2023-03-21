namespace: io.cloudslang.carbon_footprint_project.azure
flow:
  name: get_vm_details
  inputs:
    - azure_url: 'https://management.azure.com/subscriptions'
    - subscription_id: 4d08f192-8c63-49fa-a461-5cdd32ce42dc
    - api_version: '2022-11-01'
    - trust_all_roots:
        default: 'true'
        required: false
    - x_509_hostname_verifier:
        default: allow_all
        required: false
  workflow:
    - get_token:
        do:
          io.cloudslang.carbon_footprint_project.azure.get_token: []
        publish:
          - azure_token
          - list: "${'servername,vmid,location,vmsize,cpus,memory'+'\\n\\r'}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: http_client_get
    - get_list_of_servers:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: '$.value[*].name'
        publish:
          - servers: "${cs_replace(return_result.strip('[').strip(']'),'\"','',)}"
        navigate:
          - SUCCESS: list_iterator
          - FAILURE: on_failure
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${azure_url+'/'+subscription_id+'/providers/Microsoft.Compute/virtualMachines?api-version='+api_version}"
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - headers: "${'Authorization: Bearer '+azure_token}"
            - content_type: application/json
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: get_list_of_servers
          - FAILURE: on_failure
    - list_iterator:
        do:
          io.cloudslang.base.lists.list_iterator:
            - list: '${servers}'
            - separator: ','
        publish:
          - server: '${result_string}'
        navigate:
          - HAS_MORE: get_vmsize
          - NO_MORE: SUCCESS
          - FAILURE: on_failure
    - get_vmsize:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: "${'$..value[?(@.name == \"'+server+'\")].properties.hardwareProfile.vmSize'}"
        publish:
          - vmsize: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_location
          - FAILURE: on_failure
    - get_location:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: "${'$..value[?(@.name == \"'+server+'\")].location'}"
        publish:
          - location: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_vmid
          - FAILURE: on_failure
    - get_vmid:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: "${'$..value[?(@.name == \"'+server+'\")].properties.vmId'}"
        publish:
          - vmid: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: query_vm_details
          - FAILURE: on_failure
    - build_list:
        do:
          io.cloudslang.base.strings.append:
            - origin_string: '${list}'
            - text: "${server+','+vmid+','+location+','+vmsize+','+cpus+','+memory+'\\n\\r'}"
        publish:
          - list: '${new_string}'
        navigate:
          - SUCCESS: list_iterator
    - query_vm_details:
        do:
          io.cloudslang.carbon_footprint_project.azure.query_vm_details:
            - image_name: '${vmsize}'
        publish:
          - cpus
          - memory
        navigate:
          - FAILURE: on_failure
          - SUCCESS: build_list
  outputs:
    - azure_server_list: '${list}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      get_list_of_servers:
        x: 400
        'y': 120
      get_vmsize:
        x: 240
        'y': 320
      list_iterator:
        x: 80
        'y': 320
        navigate:
          a47cdb3f-74e6-05b8-aac1-5f880a0009b7:
            targetId: c01cab71-dfd0-f554-9dbb-6cda97d840d6
            port: NO_MORE
      build_list:
        x: 320
        'y': 520
      get_token:
        x: 80
        'y': 120
      query_vm_details:
        x: 560
        'y': 520
      http_client_get:
        x: 240
        'y': 120
      get_vmid:
        x: 560
        'y': 320
      get_location:
        x: 400
        'y': 320
    results:
      SUCCESS:
        c01cab71-dfd0-f554-9dbb-6cda97d840d6:
          x: 80
          'y': 520
