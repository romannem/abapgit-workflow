CLASS zcl_custom_settlement DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_custom_settlement IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    IF io_request->is_data_requested( ).

      DATA(lv_top)     = io_request->get_paging( )->get_page_size( ).
      IF lv_top < 0.
        lv_top = 1.
      ENDIF.

      DATA(lv_skip)    = io_request->get_paging( )->get_offset( ).

      DATA(lt_sort)    = io_request->get_sort_elements( ).

      DATA : lv_orderby TYPE string.
      LOOP AT lt_sort INTO DATA(ls_sort).
        IF ls_sort-descending = abap_true.
          lv_orderby = |'{ lv_orderby } { ls_sort-element_name } DESCENDING '|.
        ELSE.
          lv_orderby = |'{ lv_orderby } { ls_sort-element_name } ASCENDING '|.
        ENDIF.
      ENDLOOP.
      IF lv_orderby IS INITIAL.
        lv_orderby = 'COMPANYCODE'.
      ENDIF.

      DATA(lv_conditions) =  io_request->get_filter( )->get_as_sql_string( ).

      SELECT FROM I_OperationalAcctgDocItem
        FIELDS CompanyCode, ClearingJournalEntry
        WHERE (lv_conditions)
        ORDER BY (lv_orderby)
        INTO TABLE @DATA(flights)
        UP TO @lv_top ROWS OFFSET @lv_skip.

      IF io_request->is_total_numb_of_rec_requested(  ).
        io_response->set_total_number_of_records( lines( flights ) ).
        io_response->set_data( flights ).
      ENDIF.

    ENDIF.
  ENDMETHOD.

ENDCLASS.
