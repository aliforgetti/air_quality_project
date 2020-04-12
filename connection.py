import pymysql
import numpy as np
import streamlit as st 
import pandas as pd

#Login Info
username = st.sidebar.text_input('Enter username...')
password = st.sidebar.text_input('Enter Password...')


if (username=='admin' and password =='root'):
    

    conn = pymysql.connect('localhost','root','qwerty.123','project_2')
    # cursor = conn.cursor()
    # cursor.execute('SELECT * from mega_table')
    # row = cursor.fetchone()
    # print(row)
    # conn.close()
    query1= 'SELECT * from state_info'
    query2= 'SELECT * from loc_info'
    query3= 'SELECT * from measurement_info LIMIT 1000'
    query4= 'SELECT * from reading_info LIMIT 1000'
    query5= 'SELECT * from validation_info LIMIT 1000'


    sdf = pd.read_sql(query1,conn)
    ldf = pd.read_sql(query2,conn)
    mdf = pd.read_sql(query3,conn)
    rdf = pd.read_sql(query4,conn)
    vdf = pd.read_sql(query5,conn)


    st.title('AIR QUALITY PROJECT')
    st.markdown('The Environmental Protection Agency (EPA) creates air quality trends using measurements from monitors located across the country. All of this data comes from EPA’s Air Quality System (AQS). Data collection agencies report their data to the EPA via this system and it calculates several types of aggregate (summary) data for EPA internal use. \n')
    st.markdown('We have divided the dataset into 5 sub-tables -  ')
    '''
    1. State_info
    2. Loc_info
    3. Measurement_info
    4. Reading_info
    5. Validation_info
    '''
    st.sidebar.markdown('To see the dataframes, click on following :') 
    if st.sidebar.checkbox('State_info'):
        st.text('State_info table :')
        sdf
    if st.sidebar.checkbox('Loc_info'):
        st.text('Loc_info table :')
        ldf
    if st.sidebar.checkbox('Measurement_info'):
        st.text('Measurement_info table :')
        mdf
    if st.sidebar.checkbox('Reading_info'):
        st.text('Reading_info table :')
        rdf
    if st.sidebar.checkbox('Validation_info'):
        st.text('Validation_info table :')
        vdf

    if st.checkbox('Click here if you want to check States by state_code'):
        
        state = st.selectbox("Select the state code: ",[ 0,  1,  2,  4,  5,  6,  8,  9, 10, 11, 12, 13, 15, 16, 17, 18, 19,
            20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
            37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55,
            56, 66, 72, 78, 80])
        if state in sdf['state_code']:
            st.write(sdf.loc[sdf['state_code']==state])


            

    state_code = st.slider('state_code',0,80,0,1)
    #df = df[df['state_code']== state_code]

    conn.close()

else:
    st.header("You don't have access to this top-secret project.")