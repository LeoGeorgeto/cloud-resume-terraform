import json
import os
import boto3
from decimal import Decimal
from botocore.exceptions import ClientError

# Helper class to convert Decimal to int
class DecimalEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, Decimal):
            return int(obj)
        return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
    try:
        # Initialize DynamoDB client
        dynamodb = boto3.resource('dynamodb')
        table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
        
        try:
            # Update visitor count
            response = table.update_item(
                Key={'id': 'visitor_count'},
                UpdateExpression='ADD #count :incr',
                ExpressionAttributeNames={'#count': 'count'},
                ExpressionAttributeValues={':incr': 1},
                ReturnValues='UPDATED_NEW'
            )
            
            count = response['Attributes']['count']
            
            return {
                'statusCode': 200,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                'body': json.dumps({'count': count}, cls=DecimalEncoder)
            }
            
        except ClientError as e:
            print(f"DynamoDB Error: {str(e)}")
            return {
                'statusCode': 500,
                'headers': {
                    'Access-Control-Allow-Origin': '*',
                    'Access-Control-Allow-Methods': 'GET',
                    'Access-Control-Allow-Headers': 'Content-Type'
                },
                'body': json.dumps({'error': f"DynamoDB error: {str(e)}"})
            }
            
    except Exception as e:
        print(f"Unexpected error: {str(e)}")
        return {
            'statusCode': 500,
            'headers': {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET',
                'Access-Control-Allow-Headers': 'Content-Type'
            },
            'body': json.dumps({'error': f"Unexpected error: {str(e)}"})
        }