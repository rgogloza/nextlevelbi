import streamlit as st
import pandas as pd
import os

def read_csv(path: str, file_name: str) -> pd.DataFrame:
    return pd.read_csv(os.path.join(path,'in',file_name),sep=',')

def df_unstack_and_cleanup(df: pd.DataFrame):
    df = df.unstack().reset_index()
    df = df.drop(axis=1, labels=["level_1"])
    return df.rename(columns={"level_0":"column_name"})

def compare_df(df1: pd.DataFrame, df2: pd.DataFrame, is_diff = False):
    df1 = df_unstack_and_cleanup(df1)
    df2 = df_unstack_and_cleanup(df2)

    compared_df = df1.compare(df2, keep_shape=True, keep_equal=True, align_axis=1)
    compared_df.columns = ['to_drop','column_names','current','redesign']
    compared_df = compared_df.drop(axis=1,labels=["to_drop"])
    compared_df['is_diff'] = compared_df.apply(lambda row: row['current'] != row['redesign'], axis=1) 
    #apply is diff filtering
    compared_df = compared_df[compared_df['is_diff'] == is_diff] if is_diff == True else compared_df
    #print(compared_df.index)
    return compared_df

INIT_MSG_ORDER = "Put order id (ex. 900502)"
INIT_PUT_UNIT = "Waiting for your action. Put order id above to start."

st.title('Data Quality comparison')
unit_id = st.text_input('Order Id', INIT_MSG_ORDER)
only_diff = st.toggle('Only diff')

base_dir = os.path.dirname(__file__)
if unit_id != INIT_MSG_ORDER:
    df1 = read_csv(base_dir, 'current.csv')
    df2 = read_csv(base_dir, 'redesign.csv')

    compared_df = compare_df(df1, df2, only_diff)

    st.dataframe(compared_df, hide_index=True)
else:
    st.subheader(INIT_PUT_UNIT)
