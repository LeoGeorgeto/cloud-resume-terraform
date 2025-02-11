import json
import os
import boto3
from decimal import Decimal
from botocore.exceptions import ClientError

# Custom JSON encoder to handle DynamoDB Decimal type
# DynamoDB returns numbers as Decimal type which isn't JSON serializable
class DecimalEncoder(json.JSONEncoder):
   def default(self, obj):
       # Convert Decimal objects to integers for JSON serialization
       if isinstance(obj, Decimal):
           return int(obj)
       return super(DecimalEncoder, self).default(obj)

def lambda_handler(event, context):
   try:
       # Initialize connection to DynamoDB using boto3
       # Uses environment variables for configuration
       dynamodb = boto3.resource('dynamodb')
       table = dynamodb.Table(os.environ['DYNAMODB_TABLE'])
       
       try:
           # Attempt to increment the visitor counter in DynamoDB
           # Uses atomic ADD operation to ensure accuracy with concurrent requests
           response = table.update_item(
               Key={'id': 'visitor_count'},                    # Primary key of the counter item
               UpdateExpression='ADD #count :incr',           # Increment the count
               ExpressionAttributeNames={'#count': 'count'},  # Avoid reserved word 'count'
               ExpressionAttributeValues={':incr': 1},        # Increment by 1
               ReturnValues='UPDATED_NEW'                     # Return the new count
           )
           
           # Extract the new count value from the response
           count = response['Attributes']['count']
           
           # Return successful response with CORS headers
           return {
               'statusCode': 200,
               'headers': {
                   'Access-Control-Allow-Origin': '*',           # Allow requests from any origin
                   'Access-Control-Allow-Methods': 'GET',        # Only allow GET requests
                   'Access-Control-Allow-Headers': 'Content-Type'
               },
               'body': json.dumps({'count': count}, cls=DecimalEncoder)  # Use custom encoder
           }
           
       except ClientError as e:
           # Handle DynamoDB-specific errors
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
       # Handle any other unexpected errors
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