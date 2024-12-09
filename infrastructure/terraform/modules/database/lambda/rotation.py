# pylint: disable=import-error
"""
Lambda function for handling PostgreSQL RDS password rotation via AWS Secrets Manager.

This module implements automatic password rotation for RDS PostgreSQL instances
using AWS Secrets Manager. It generates secure passwords and updates both the
RDS instance and the corresponding secret.
"""
import json
import logging
import string
import random
import boto3 # type: ignore

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, _context):
    """Handles the secret rotation for PostgreSQL RDS instance."""

    if not event.get('SecretId') or not event.get('ClientRequestToken'):
        raise ValueError("SecretId and ClientRequestToken are required.")

    secret_id = event['SecretId']
    token = event['ClientRequestToken']

    # Initialize AWS clients
    session = boto3.session.Session()
    secrets_client = session.client('secretsmanager')
    rds_client = session.client('rds')

    try:
        # Get the secret
        secret = secrets_client.get_secret_value(SecretId=secret_id)
        secret_data = json.loads(secret['SecretString'])

        # Generate new password
        new_password = generate_password()

        # Update secret with new password
        new_secret_data = secret_data.copy()
        new_secret_data['password'] = new_password

        # Update RDS instance password
        try:
            rds_client.modify_db_instance(
                DBInstanceIdentifier=secret_data.get('dbInstanceIdentifier', ''),
                MasterUserPassword=new_password,
                ApplyImmediately=True
            )

            # Update the secret with new password
            secrets_client.put_secret_value(
                SecretId=secret_id,
                ClientRequestToken=token,
                SecretString=json.dumps(new_secret_data)
            )

            logger.info("Successfully rotated secret for %s", secret_id)
            return {
                'statusCode': 200,
                'body': 'Secret rotated successfully'
            }

        except Exception as e:
            logger.error("Error updating RDS password: %s", str(e))
            raise

    except Exception as e:
        logger.error("Error rotating secret: %s", str(e))
        raise

def generate_password(length=32):
    """Generate a secure password."""

    # Define character sets
    uppercase = string.ascii_uppercase
    lowercase = string.ascii_lowercase
    digits = string.digits
    special = "!@#$%^&*()_+-=[]{}|;:,.<>?"

    # Ensure at least one of each type
    password = [
        random.choice(uppercase),
        random.choice(lowercase),
        random.choice(digits),
        random.choice(special)
    ]

    # Fill the rest with random characters from all sets
    all_chars = uppercase + lowercase + digits + special
    password.extend(random.choice(all_chars) for _ in range(length - 4))

    # Shuffle the password
    random.shuffle(password)

    return ''.join(password)
