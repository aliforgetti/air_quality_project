import pymysql
import numpy as np
import streamlit as st 
import pandas as pd
import plotly.express as px
from PIL import Image

#Login Info
username = st.sidebar.text_input('Enter username...')
password = st.sidebar.text_input('Enter Password...')


if (username=='admin' and password =='root'):
    

    conn = pymysql.connect('localhost','root','qwerty.123','project_2')
    cursor = conn.cursor()
    # cursor.execute('SELECT * from mega_table')
    # row = cursor.fetchone()
    # print(row)
    # conn.close()
    query1= 'SELECT * from state_info;'
    query2= 'SELECT * from loc_info;'
    query3= 'SELECT * from measurement_info LIMIT 1000;'
    query4= 'SELECT * from reading_info LIMIT 1000;'
    query5= 'SELECT * from validation_info LIMIT 1000;'
    query6= 'SELECT * FROM last_four;'
    query7= 'SELECT * FROM parameter_info;'


    sdf = pd.read_sql(query1,conn)
    ldf = pd.read_sql(query2,conn)
    mdf = pd.read_sql(query3,conn)
    rdf = pd.read_sql(query4,conn)
    vdf = pd.read_sql(query5,conn)
    pdf = pd.read_sql(query7,conn)
    view = pd.read_sql(query6,conn)


    st.title('AIR QUALITY PROJECT')
    st.markdown('The Environmental Protection Agency (EPA) creates air quality trends using measurements from monitors located across the country. All of this data comes from EPA’s Air Quality System (AQS). Data collection agencies report their data to the EPA via this system and it calculates several types of aggregate (summary) data for EPA internal use. \n')
    st.markdown('We created a database using this dataset and split it up into the following tables -')
    '''
    1. State_info
    2. Loc_info
    3. Measurement_info
    4. Reading_info
    5. Validation_info
    6. Parameter_info
    
    '''
    st.subheader('')
    st.header('Heatmap for Pollutants in USA')


    params = st.selectbox('Select the Pollutant: ',['Ozone','Nitrogen dioxide (NO2)','Sulfur dioxide','Carbon monoxide','Carbon dioxide'])
    states = st.selectbox("Select the State: ",['Alabama','Alaska','Arizona','Arkansas','California','Colorado','Connecticut','Delaware',
 'District Of Columbia','Florida','Georgia','Hawaii','Idaho','Illinois','Indiana','Iowa','Kansas','Kentucky','Louisiana',
 'Maine','Maryland','Massachusetts','Michigan','Minnesota','Mississippi','Missouri','Montana','Nebraska','Nevada','New Hampshire',
 'New Jersey','New Mexico','New York','North Carolina','North Dakota','Ohio','Oklahoma','Oregon','Pennsylvania','Rhode Island',
 'South Carolina','South Dakota','Tennessee','Texas','Utah','Vermont','Virginia','Washington','West Virginia','Wisconsin',
 'Wyoming','Puerto Rico','Virgin Islands','Country Of Mexico'])
    

    def plot_heatmap(df, parameter, state):
        latitude = df[df['state_name']== state][['latitude','longitude']].mean(axis = 0)['latitude']
        longitude = df[df['state_name']== state][['latitude','longitude']].mean(axis = 0)['longitude']    
        df = df[df['parameter_name']==parameter]
        fig = px.density_mapbox(df,\
                                lat='latitude',\
                                lon='longitude',\
                                z='arithmetic_mean',\
                                radius=10,
                                animation_frame= 'year',
                            center=dict(lat=latitude, lon=longitude), zoom=5.5,
                            mapbox_style= 'carto-positron')
        fig
        
    st.write(plot_heatmap(view,params,states))

    st.write('')
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
    if st.sidebar.checkbox('Parameter_info'):
        st.text('Parameter_info table :')
        pdf
    

    st.subheader('')
    st.subheader('Use the tools below to make changes to the database - ')

    if st.checkbox('Click here if you want to check States by state_code'):
        
        state = st.selectbox("Select the state code: ",[ 0,  1,  2,  4,  5,  6,  8,  9, 10, 11, 12, 13, 15, 16, 17, 18, 19,
            20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36,
            37, 38, 39, 40, 41, 42, 44, 45, 46, 47, 48, 49, 50, 51, 53, 54, 55,
            56, 66, 72, 78, 80])
        if state in sdf['state_code']:
            st.write(sdf.loc[sdf['state_code']==state])

    if st.checkbox('Click here to insert new data into `State_info` table.'):
        state_code = st.text_input('Enter state_code...')
        state_name = st.text_input('Enter state_name...')
        if state_code != '' and state_name!='':
            qwe = "INSERT into state_info values({0},'{1}');".format(int(state_code),state_name)
            if cursor.execute(qwe):
                st.success("Successfully Inserted! Click the box below to commit changes...")
                if st.button('Click here to commit changes...'):
                    conn.commit()
                    st.success('Succesfully committed...')

    
    if st.checkbox('Click here to delete entry from *State_info* table.'):
        state_codee = st.text_input('Enter state_code...')
        if state_codee != '':
            qwe1 = "DELETE from state_info WHERE state_code = {};".format(int(state_codee))
            if cursor.execute(qwe1):
                st.success("Successfully Inserted! Click the box below to commit changes...")
                if st.button('Click here to commit changes...'):
                    conn.commit()
                    st.success('Succesfully committed...')

    if st.checkbox('Click here to insert into *Loc_info* table'):
        st_code = st.text_input('Enter state_code...')
        ct_code = st.text_input('Enter county_code...')
        st_num = st.text_input('Enter site_num...')
        ct_name = st.text_input('Enter county_name...')
        city = st.text_input('Enter city_name...')
        lati = st.text_input('Enter latitude...')
        longi = st.text_input('Enter longitude...')
        lcl_name = st.text_input('Enter local_site_name...')
        cbsa = st.text_input('Enter cbsa_name...')

        if (st_code and ct_code and st_num and ct_name and city and lati and longi and lcl_name and cbsa)!='':

            qwe2 = "INSERT INTO loc_info values({},{},{},'{}','{}',{},{},'{}','{}');".format(int(st_code),int(ct_code),int(st_num),
            ct_name,city,float(lati),float(longi),lcl_name,cbsa)
            if cursor.execute(qwe2):
                st.success("Successfully Inserted! Click the box below to commit changes...")
                if st.button('Click here to commit changes...'):
                    conn.commit()
                    st.success('Succesfully committed...')


    if st.checkbox('Click here to delete entry from *Loc_info* table'):
        st_codee = st.text_input('Enter state_code...')
        ct_codee = st.text_input('Enter county_code...')
        st_nume = st.text_input('Enter site_num...')

        if (st_codee and ct_codee and st_nume )!='':

            qwe3 = "DELETE FROM loc_info WHERE state_code={0} AND county_code={1} AND site_num = {3}; ".format(int(st_codee),int(ct_codee),int(st_nume))
            if cursor.execute(qwe3):
                st.success("Successfully Inserted! Click the box below to commit changes...")
                if st.button('Click here to commit changes...'):
                    conn.commit()
                    st.success('Succesfully committed...')

    
 

    

            
              


    
    conn.close()

else:
    img = Image.open('IMG_3720.jpeg')
    st.header("Sorry to say, you don't have access to this top-secret project...")
    st.image(img,width=300,caption='Uh-Ohhh')
 

 