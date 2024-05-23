import streamlit as st
import pandas as pd
import os
from datetime import datetime

INIT_MSG_ORDER = 'Put order id (ex. 900502)'
INIT_PUT_UNIT = 'Waiting for your action. Put order id above to start.'
SESSION_PARAM_EDITED_DF = 'edited_df'
SESSION_PARAM_BASE_DIR = 'base_dir'
SESSION_PARAM_UNIT_ID = 'unit_id'


def read_csv(path: str, file_name: str) -> pd.DataFrame:
    return pd.read_csv(os.path.join(path,'in',file_name),sep=',')

def save_csv(path: str, file_name: str, df: pd.DataFrame):
    df.to_csv(os.path.join(path,'out',file_name), sep=',', index=False)

def df_unstack_and_cleanup(df: pd.DataFrame):
    df = df.unstack().reset_index()
    df = df.drop(axis=1, labels=['level_1'])
    return df.rename(columns={'level_0':'column_name'})

def compare_df(df1: pd.DataFrame, df2: pd.DataFrame, is_diff = False):
    df1 = df_unstack_and_cleanup(df1)
    df2 = df_unstack_and_cleanup(df2)

    compared_df = df1.compare(df2, keep_shape=True, keep_equal=True, align_axis=1)
    compared_df.columns = ['to_drop','column_names','current','redesign']
    compared_df = compared_df.drop(axis=1,labels=['to_drop'])
    #calculating is diff column
    compared_df['is_diff'] = compared_df.apply(lambda row: row['current'] != row['redesign'], axis=1) 
    compared_df['comment'] = ''
    #apply is diff filtering
    compared_df = compared_df[compared_df['is_diff'] == is_diff] if is_diff == True else compared_df
    return compared_df

# saving modified data frame
def save_modified_df():
    df = st.session_state[SESSION_PARAM_EDITED_DF]
    base_dir = st.session_state[SESSION_PARAM_BASE_DIR]
    unit_id = st.session_state[SESSION_PARAM_UNIT_ID]
    save_csv(base_dir, f"{unit_id}.csv", df)

# add oaraneter to session state
def add_session_parameter(session_state, paramaeter_name: str, parameter_value):
    session_state[paramaeter_name] = parameter_value


st.title('Data Quality comparison')
unit_id = st.text_input('Order Id', INIT_MSG_ORDER)
only_diff = st.toggle('Only diff')
base_dir = os.path.dirname(__file__)

# if edited df not in session state then initializing
if 'edited_df' not in st.session_state:
    add_session_parameter(st.session_state, SESSION_PARAM_EDITED_DF, None)

# adding to session state base dir name
if 'base_dir' not in st.session_state:
    add_session_parameter(st.session_state, SESSION_PARAM_BASE_DIR, base_dir)

# adding unit id to session state
if unit_id != INIT_MSG_ORDER:
    add_session_parameter(st.session_state, SESSION_PARAM_UNIT_ID, unit_id)

# adding button and defining method to be called when butthon is clicked
st.button('Save', on_click = save_modified_df)

if unit_id != INIT_MSG_ORDER:
    df1 = read_csv(base_dir, 'current.csv')
    df2 = read_csv(base_dir, 'redesign.csv')

    compared_df = compare_df(df1, df2, only_diff)
    # defining streamlit data editor and storing modified state in edited_df
    # colum config defines kolum name, column type and if column is editable
    # only comment column will be editable
    edited_df = st.data_editor(compared_df,
        column_config={
            "column_names": st.column_config.TextColumn(
                "Column Name",
                help="Dataset column name",
                disabled=True   
            ),
            'current': st.column_config.TextColumn(
                'Current',
                help='Current dataset value',
                disabled=True   
            ),
            "redesign": st.column_config.TextColumn(
                "Redesign",
                help="Redesign dataset value",
                disabled=True   
            ),
            "is_diff": st.column_config.CheckboxColumn(
                "Is Diff",
                help="Is difference between two datasets",
                disabled=True   
            ),
            'comment': st.column_config.TextColumn(
                'Comment',
                help='Should any action be taken?',
                disabled=False   
            )
        }, hide_index=True)

    # adding edited df to the session state
    st.session_state[SESSION_PARAM_EDITED_DF] = pd.DataFrame(edited_df)