########################################################################################################################
#!!
#! @description: Place one record in the ODL table
#!!#
########################################################################################################################
namespace: io.cloudslang.carbon_footprint_project.optic_data_lake
flow:
  name: odl_load_data
  inputs:
    - odl_url: 'https://optic.advantageinc.org:30001/itom-data-ingestion-receiver'
    - schema_name: dcoe_esg
    - timestamp
    - scope2_co2e
    - scope3_co2e
    - powerusage
    - cmdb_id:
        default: ' '
        required: false
    - cmdb_global_id:
        default: ' '
        required: false
    - node_fqdn
    - node_ip_address
  workflow:
    - get_token:
        do:
          io.cloudslang.carbon_footprint_project.optic_data_lake.get_token: []
        publish:
          - token
        navigate:
          - SUCCESS: http_client_post
          - FAILURE: on_failure
    - http_client_post:
        do:
          io.cloudslang.base.http.http_client_post:
            - url: '${odl_url}'
            - headers: "${'Authorization: Bearer '+token}"
            - body: "${'{'+\\\n'   \"timestamp_utc_s\": '+timestamp+','+\\\n'   \"scope2_co2e\": '+scope2_co2e+','+\\\n'   \"scope3_co2e\": '+scope3_co2e+','+\\\n'   \"powerUsage\": '+powerusage+','+\\\n'   \"cmdb_id\": \"'+cmdb_id+'\",'+\\\n'   \"cmdb_global_id\": \"'+cmdb_global_id+'\",'+\\\n'   \"node_fqdn\": \"'+node_fqdn+'\",'+\\\n'   \"node_ip_address\": \"'+node_ip_address+'\"'+\\\n'}'}"
            - content_type: "application\\json"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - SUCCESS
    - FAILURE
extensions:
  graph:
    steps:
      http_client_post:
        x: 320
        'y': 200
        navigate:
          4433f714-c162-1864-bf32-8490afa36836:
            targetId: f56b79ea-ffbb-8d3b-7ca5-f9e0c05748ad
            port: SUCCESS
      get_token:
        x: 120
        'y': 120
    results:
      SUCCESS:
        f56b79ea-ffbb-8d3b-7ca5-f9e0c05748ad:
          x: 520
          'y': 200
