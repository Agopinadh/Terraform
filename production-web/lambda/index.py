import json
import os


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps(
            {
                "application": os.environ.get("APP_NAME", "production-web"),
                "message": "API is healthy",
            }
        ),
    }
