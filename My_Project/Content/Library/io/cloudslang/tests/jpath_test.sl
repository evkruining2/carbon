namespace: io.cloudslang.tests
flow:
  name: jpath_test
  inputs:
    - json_result: |-
        ${'''
        [
            {
                "name":"you can't find me",
                "id":"1234"
            },
                {
                "name":"you can find me",
                "id":"2345"
            },
                {
                "name":"you can find me also",
                "id":"3456"
            }
        ]
        '''}
  workflow:
    - json_path_query:
        do:
          io.cloudslang.base.json.json_path_query:
            - json_object: '${json_result}'
            - json_path: "${'''$.[?(@.name==\"you can't find me\")]'''}"
        navigate:
          - SUCCESS: SUCCESS
          - FAILURE: on_failure
  results:
    - FAILURE
    - SUCCESS
extensions:
  graph:
    steps:
      json_path_query:
        x: 240
        'y': 120
        navigate:
          d941523c-a693-1342-26f0-fc333674a5c3:
            targetId: 3a8b2d75-8fcb-8a3a-65ed-6efab54e5e2a
            port: SUCCESS
    results:
      SUCCESS:
        3a8b2d75-8fcb-8a3a-65ed-6efab54e5e2a:
          x: 440
          'y': 160
