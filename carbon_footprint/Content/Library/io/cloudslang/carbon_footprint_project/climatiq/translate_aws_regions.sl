namespace: io.cloudslang.carbon_footprint_project.climatiq
flow:
  name: translate_aws_regions
  inputs:
    - aws_region
  workflow:
    - get_aws_regions:
        do:
          io.cloudslang.base.utils.do_nothing: []
        publish:
          - json_result: |-
              ${{
                  "value" : [
                {"af-south-1": "af_south_1"},
                {"ap-east-1": "ap_east_1"},
                {"ap-northeast-1": "ap_northeast_1"},
                {"ap-northeast-2": "ap_northeast_2"},
                {"ap-northeast-3": "ap_northeast_3"},
                {"ap-south-1": "ap_south_1"},
                {"ap-southeast-1": "ap_southeast_1"},
                {"ap-southeast-2": "ap_southeast_2"},
                {"ca-central-1": "ca_central_1"},
                {"cn-north-1": "cn_north_1"},
                {"cn-northwest-1": "cn_northwest_1"},
                {"eu-central-1": "eu_central_1"},
                {"eu-north-1": "eu_north_1"},
                {"eu-south-1": "eu_south_1"},
                {"eu-west-1": "eu_west_1"},
                {"eu-west-2": "eu_west_2"},
                {"eu-west-3": "eu_west_3"},
                {"me-south-1": "me_south_1"},
                {"sa-east-1": "sa_east_1"},
                {"us-east-1": "us_east_1"},
                {"us-east-2": "us_east_2"},
                {"us-gov-east-1": "us_gov_east_1"},
                {"us-gov-west-1": "us_gov_west_1"},
                {"us-west-1": "us_west_1"},
                {"us-west-2": "us_west_2"}
              ]
              }}
        navigate:
          - SUCCESS: map_climatiq_region
          - FAILURE: on_failure
    - map_climatiq_region:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: "${'$.value..'+aws_region}"
        publish:
          - region: "${return_result.strip('[').strip(']').strip('\"')}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  outputs:
    - region: '${region}'
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      map_climatiq_region:
        x: 320
        'y': 120
        navigate:
          65613f40-1869-3d86-125b-b9d47082b831:
            targetId: 5d687388-4ea7-e7da-e42f-94256bbab6d3
            port: SUCCESS
      get_aws_regions:
        x: 120
        'y': 120
    results:
      SUCCESS:
        5d687388-4ea7-e7da-e42f-94256bbab6d3:
          x: 560
          'y': 120
