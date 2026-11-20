import json
import os


def handler(event, context):
    return {
        "statusCode": 200,
        "headers": {"content-type": "application/json"},
        "body": json.dumps({
            "status": "ok",
            "database": os.environ["DB_NAME"],
            "database_check": "not performed by this health route",
        }),
    }
