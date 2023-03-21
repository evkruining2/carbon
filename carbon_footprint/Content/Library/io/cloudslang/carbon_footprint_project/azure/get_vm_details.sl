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
          - list: "${'servername,vmid,location,vmsize,cpus,memory,ip_address,fqdn,total_co2e'+'\\n\\r'}"
        navigate:
          - FAILURE: on_failure
          - SUCCESS: http_client_get
    - get_list_of_servers:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${master_json_result}'
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
          - master_json_result: '${return_result}'
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
            - json_object: '${master_json_result}'
            - json_path: "${'$..value[?(@.name == \"'+server+'\")].properties.hardwareProfile.vmSize'}"
        publish:
          - vmsize: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_location
          - FAILURE: on_failure
    - get_location:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${master_json_result}'
            - json_path: "${'$..value[?(@.name == \"'+server+'\")].location'}"
        publish:
          - location: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_vmid
          - FAILURE: on_failure
    - get_vmid:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${master_json_result}'
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
            - text: "${server+','+vmid+','+location+','+vmsize+','+cpus+','+memory+','+ip_address+','+fqdn+','+total_co2e+'\\n\\r'}"
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
          - SUCCESS: get_network
    - get_network:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${master_json_result}'
            - json_path: "${'$..value[?(@.name == \"'+server+'\")].properties.networkProfile.networkInterfaces..id'}"
        publish:
          - network_id: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_public_network
          - FAILURE: on_failure
    - get_public_network:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${'https://management.azure.com/'+network_id+'?api-version='+api_version}"
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - headers: "${'Authorization: Bearer '+azure_token}"
            - content_type: application/json
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: get_public_interface_id
          - FAILURE: on_failure
    - get_public_interface_id:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: "${'$..[?(@.name == \"'+server+'\")].properties.publicIPAddress.id'}"
        publish:
          - pub_network_id: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_pub_ip_and_fqdn
          - FAILURE: on_failure
    - get_pub_ip_and_fqdn:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: "${'https://management.azure.com/'+pub_network_id+'?api-version='+api_version}"
            - trust_all_roots: '${trust_all_roots}'
            - x_509_hostname_verifier: '${x_509_hostname_verifier}'
            - headers: "${'Authorization: Bearer '+azure_token}"
            - content_type: application/json
        publish:
          - json_result: '${return_result}'
        navigate:
          - SUCCESS: get_ip
          - FAILURE: set_ip_and_fqdn_to_null
    - get_ip:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: $.properties.ipAddress
        publish:
          - ip_address: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: get_ip_1
          - FAILURE: on_failure
    - get_ip_1:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: $.properties.dnsSettings.fqdn
        publish:
          - fqdn: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: query_vm_details_1
          - FAILURE: on_failure
    - query_vm_details_1:
        do:
          io.cloudslang.carbon_footprint_project.azure.query_vm_details:
            - image_name: '${vmsize}'
        publish:
          - cpus
          - memory
        navigate:
          - FAILURE: on_failure
          - SUCCESS: translate_azure_regions
    - translate_azure_regions:
        do:
          io.cloudslang.carbon_footprint_project.climatiq.translate_azure_regions:
            - az_region: '${location}'
        publish:
          - region
        navigate:
          - FAILURE: on_failure
          - SUCCESS: azure_vm_instance
    - azure_vm_instance:
        do:
          io.cloudslang.carbon_footprint_project.climatiq.azure_vm_instance:
            - region: '${region}'
            - cpu_count: '${cpus}'
            - memory: '${memory}'
        publish:
          - total_co2e
        navigate:
          - FAILURE: on_failure
          - SUCCESS: build_list
    - set_ip_and_fqdn_to_null:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - ip_address: 'null'
          - fqdn: 'null'
        navigate:
          - SUCCESS: query_vm_details_1
          - FAILURE: on_failure
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
        'y': 40
      get_vmsize:
        x: 240
        'y': 240
      get_public_network:
        x: 240
        'y': 440
      get_ip_1:
        x: 440
        'y': 600
      query_vm_details_1:
        x: 640
        'y': 600
      set_ip_and_fqdn_to_null:
        x: 360
        'y': 760
      get_network:
        x: 400
        'y': 440
      get_pub_ip_and_fqdn:
        x: 80
        'y': 600
      azure_vm_instance:
        x: 880
        'y': 440
      get_public_interface_id:
        x: 80
        'y': 400
      list_iterator:
        x: 600
        'y': 40
        navigate:
          a47cdb3f-74e6-05b8-aac1-5f880a0009b7:
            targetId: c01cab71-dfd0-f554-9dbb-6cda97d840d6
            port: NO_MORE
      build_list:
        x: 800
        'y': 240
      get_ip:
        x: 240
        'y': 600
      get_token:
        x: 80
        'y': 40
      query_vm_details:
        x: 560
        'y': 440
      http_client_get:
        x: 240
        'y': 40
      get_vmid:
        x: 560
        'y': 240
      translate_azure_regions:
        x: 840
        'y': 600
      get_location:
        x: 400
        'y': 240
    results:
      SUCCESS:
        c01cab71-dfd0-f554-9dbb-6cda97d840d6:
          x: 920
          'y': 40
