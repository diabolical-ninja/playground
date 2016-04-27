val drop_cols = array('quarter','stock','date')


dow_jones_index.select(dow_jones_index.columns.filter(_!=drop_cols))