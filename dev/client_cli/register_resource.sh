curl --location --silent --request PUT 'http://127.0.0.1:4001/v1/access/resource' \
--header 'Content-Type: application/json' \
--data '{
    "role": "ROLE_VERIFICATION_BODY_10",
    "policy_contract": "0x04756f72242049Eb05A0BAADa41E0F46828122cD",
    "resource": "static/data/emission_report.csv"
}'
