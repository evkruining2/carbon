namespace: io.cloudslang.carbon_footprint_project.test
flow:
  name: get_compute_provisers_and_regions
  inputs:
    - climatiq_token: Y3Q5BATS8TM2ARKBB18Y8MN95HX1
  workflow:
    - http_client_get:
        do:
          io.cloudslang.base.http.http_client_get:
            - url: 'https://beta3.api.climatiq.io/compute'
            - proxy_host: 10.0.0.1
            - proxy_port: '3128'
            - headers: "${'Authorization: Bearer '+climatiq_token}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      http_client_get:
        x: 200
        'y': 120
        navigate:
          1d8d4734-f8d7-7d17-da1f-876bb4b7f254:
            targetId: 2c2d10db-e888-e3ba-f167-e60ab32ee826
            port: SUCCESS
    results:
      SUCCESS:
        2c2d10db-e888-e3ba-f167-e60ab32ee826:
          x: 400
          'y': 160
