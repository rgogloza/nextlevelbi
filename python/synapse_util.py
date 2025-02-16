import pyodbc, struct
import os
from dotenv import load_dotenv
load_dotenv()


class SynapseUtil:
    tenant_id = os.getenv('tenant_id')
    client_id = os.getenv('client_id')
    client_secret = os.getenv('client_secret')
    default_database = os.getenv('default_database')
    default_server = os.getenv('default_server')
    connection_string = f"Driver={{ODBC Driver 18 for SQL Server}};Server={default_server};Database={default_database};Encrypt=yes;Connection Timeout=30"
    db_scope = 'https://database.windows.net/.default'
    token = None

    @staticmethod
    def get_token():
        from azure.identity import ClientSecretCredential
        auth = ClientSecretCredential(authority='https://login.microsoftonline.com/',
                                                        tenant_id=SynapseUtil.tenant_id,
                                                        client_id=SynapseUtil.client_id,
                                                        client_secret=SynapseUtil.client_secret)
        access_token = auth.get_token(SynapseUtil.db_scope)
        SynapseUtil.token = access_token.token
        return SynapseUtil.token

    @staticmethod
    # https://learn.microsoft.com/en-us/azure/azure-sql/database/azure-sql-python-quickstart?view=azuresql&tabs=windows%2Csql-auth
    def get_conn():
        if SynapseUtil.token is None:
            SynapseUtil.get_token()

        token_bytes = SynapseUtil.token.encode("UTF-16-LE")
        token_struct = struct.pack(f'<I{len(token_bytes)}s', len(token_bytes), token_bytes)
        SQL_COPT_SS_ACCESS_TOKEN = 1256  # This connection option is defined by microsoft in msodbcsql.h
        return pyodbc.connect(SynapseUtil.connection_string, attrs_before={SQL_COPT_SS_ACCESS_TOKEN: token_struct})


conn = SynapseUtil.get_conn()

