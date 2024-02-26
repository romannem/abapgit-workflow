CLASS zcl_settlement DEFINITION
    PUBLIC

    CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_settlement_data,
             settlement_id TYPE string,
             currency      TYPE string,
             customer      TYPE string,
           END OF ty_settlement_data.

    TYPES: BEGIN OF ty_bp_data,
             customername    TYPE i_customer-customerfullname,
             streetname      TYPE i_customer-streetname,
             cityname        TYPE i_customer-cityname,
             postalcode      TYPE i_customer-postalcode,
             vatregistration TYPE i_customer-vatregistration,
             taxnumber1      TYPE i_customer-taxnumber1,
             taxnumber2      TYPE i_customer-taxnumber2,
           END OF ty_bp_data.

    TYPES ty_bp_data_tax_cds TYPE i_businesspartnertaxnumber.
    TYPES ty_bp_data_cds TYPE i_businesspartner.

    TYPES ty_settlement_data_cds TYPE i_operationalacctgdocitem.


    CLASS-METHODS:

      generate_settlement
        IMPORTING
          !io_settlement TYPE ty_settlement_data_cds-accountingdocument
        RAISING
          cx_web_http_client_error
          cx_http_dest_provider_error.

    INTERFACES if_oo_adt_classrun .

    CLASS-DATA: ct_settlement_data TYPE TABLE OF ty_settlement_data_cds.
    CLASS-DATA: ct_bp_data TYPE TABLE OF ty_bp_data_cds.
    CLASS-DATA: ct_bp_data_tax TYPE TABLE OF ty_bp_data_tax_cds.
    CLASS-DATA: ct_customer_data TYPE TABLE OF ty_bp_data.

PROTECTED SECTION.


  PRIVATE SECTION.

    CLASS-METHODS:
      fetch_settlement_data
        IMPORTING
          iv_settlement_id TYPE ty_settlement_data_cds-accountingdocument
        CHANGING
          ct_settlement    LIKE ct_settlement_data,

      fetch_bp_data
        IMPORTING
          iv_bp_id       TYPE ty_settlement_data_cds-customer
          iv_is_customer TYPE xsdboolean
        CHANGING
          ct_bp          LIKE ct_customer_data,

      send_settlement_data
        IMPORTING
          io_settlement_id   TYPE ty_settlement_data_cds-accountingdocument
          io_settlement_data LIKE ct_settlement_data
          io_bp_data         LIKE ct_customer_data
        RAISING
          cx_web_http_client_error
          cx_http_dest_provider_error,

      compose_request_body
        IMPORTING
          io_settlement_id       TYPE ty_settlement_data_cds-accountingdocument
          io_settlement_data     LIKE ct_settlement_data
          io_bp_data             LIKE ct_customer_data
        RETURNING
          VALUE(rv_request_body) TYPE string,

      determine_bp
        IMPORTING
                  io_settlement_data LIKE ct_settlement_data
        CHANGING  cv_is_customer     TYPE xsdboolean
        RETURNING VALUE(rv_bp)       TYPE ty_settlement_data_cds-customer.

  ENDCLASS.



CLASS zcl_settlement IMPLEMENTATION.


  METHOD compose_request_body.

    DATA: lv_json TYPE string.

    DATA(lo_json_builder) = xco_cp_json=>data->builder( ).

    READ TABLE io_bp_data ASSIGNING FIELD-SYMBOL(<lfs_bp>) INDEX 1.

    TRY.
        " Start building the JSON object
        lo_json_builder->begin_object( ).

        " SettlementID
        lo_json_builder->add_member( 'SettlementID' )->add_string( io_settlement_id ).

        " SettlementDate
        lo_json_builder->add_member( 'SettlementDate' )->add_string( cl_abap_context_info=>get_system_date( ) ).

        " SettlementRecieverDetails
          lo_json_builder->add_member( 'SettlementRecieverDetails' )->begin_object( ).
          lo_json_builder->add_member( 'FullName' )->add_string( <lfs_bp>-customername ).
          lo_json_builder->add_member( 'Address' )->begin_object( ).
          lo_json_builder->add_member( 'City' )->add_string( <lfs_bp>-cityname ).
          lo_json_builder->add_member( 'Street' )->add_string( <lfs_bp>-streetname ).
          lo_json_builder->add_member( 'PostalCode' )->add_string( <lfs_bp>-postalcode ).
          lo_json_builder->end_object( ).
          lo_json_builder->add_member( 'Email' )->add_string( 'cpimailpoc@gmail.com' ).
          lo_json_builder->add_member( 'TAXIDs' )->begin_object( ).
          lo_json_builder->add_member( 'ICO' )->add_string( <lfs_bp>-taxnumber1 ).
          lo_json_builder->add_member( 'DIC' )->add_string( <lfs_bp>-taxnumber2 ).
          lo_json_builder->add_member( 'IC_DPH' )->add_string( <lfs_bp>-vatregistration ).
          lo_json_builder->end_object( ).

          lo_json_builder->end_object( ).
        " SettlementRecieverDetails
*        lo_json_builder->add_member( 'SettlementRecieverDetails' )->begin_object( ).
*        lo_json_builder->add_member( 'FullName' )->add_string( 'VÝCHOR s.r.o.' ).
**          lo_json_builder->add_member( 'FullName' )->add_string( <lfs_bp>-customerfullname ).
*        lo_json_builder->add_member( 'Address' )->begin_object( ).
*        lo_json_builder->add_member( 'City' )->add_string( 'Chlmec' ).
**          lo_json_builder->add_member( 'City' )->add_string( <lfs_bp>-cityname ).
*        lo_json_builder->add_member( 'Street' )->add_string( 'Chlmec' ).
*        lo_json_builder->add_member( 'HouseNumber' )->add_string( '77' ).
*        lo_json_builder->add_member( 'PostalCode' )->add_string( '06741' ).
*        lo_json_builder->end_object( ).
*        lo_json_builder->add_member( 'Email' )->add_string( 'cpimailpoc@gmail.com' ).
*        lo_json_builder->add_member( 'TAXIDs' )->begin_object( ).
*        lo_json_builder->add_member( 'ICO' )->add_string( '47436352' ).
*        lo_json_builder->add_member( 'DIC' )->add_string( '2023919513' ).
*        lo_json_builder->add_member( 'IC_DPH' )->add_string( 'SK2023919513' ).
*        lo_json_builder->end_object( ).
*        lo_json_builder->end_object( ).

        " SettlementItems
        lo_json_builder->add_member( 'SettlementItems' )->begin_array( ).
        lo_json_builder->begin_object( ).
        lo_json_builder->add_member( 'ItemsSent' )->begin_array( ).

        " Loop through and add ItemsSent data

        LOOP AT io_settlement_data ASSIGNING FIELD-SYMBOL(<lfs_sent_items>) WHERE debitcreditcode EQ 'S'.

          lo_json_builder->begin_object( ).
          lo_json_builder->add_member( 'VS' )->add_string( <lfs_sent_items>-assignmentreference ).
          lo_json_builder->add_member( 'DueDate' )->add_string( <lfs_sent_items>-netduedate ).
          lo_json_builder->add_member( 'OriginalValue' )->add_string( CONV #( <lfs_sent_items>-AmountInCompanyCodeCurrency ) ).
          lo_json_builder->add_member( 'SettledClaim' )->add_string( CONV #( <lfs_sent_items>-AmountInCompanyCodeCurrency ) ).
          lo_json_builder->add_member( 'SettledLiability' )->add_string( '0.0' ).
          lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
          lo_json_builder->end_object( ).


        ENDLOOP.

        " Add other ItemsSent objects similarly

        lo_json_builder->end_array( ).

        lo_json_builder->add_member( 'ItemsReceived' )->begin_array( ).

        LOOP AT io_settlement_data ASSIGNING FIELD-SYMBOL(<lfs_received_items>) WHERE debitcreditcode EQ 'H'.

          lo_json_builder->begin_object( ).
          lo_json_builder->add_member( 'VS' )->add_string( <lfs_received_items>-assignmentreference ).
          lo_json_builder->add_member( 'DueDate' )->add_string( <lfs_received_items>-netduedate ).
          lo_json_builder->add_member( 'OriginalValue' )->add_string( CONV #( <lfs_sent_items>-AmountInCompanyCodeCurrency ) ).
          lo_json_builder->add_member( 'SettledClaim' )->add_string( CONV #( <lfs_sent_items>-AmountInCompanyCodeCurrency ) ).
          lo_json_builder->add_member( 'SettledLiability' )->add_string( '0.0' ).
          lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
          lo_json_builder->end_object( ).


        ENDLOOP.

        lo_json_builder->end_array( ).
        lo_json_builder->end_object( ).
        lo_json_builder->end_array( ).

        " End the JSON object
        lo_json_builder->end_object( ).

        " Get the JSON string
        lv_json = lo_json_builder->get_data(  )->to_string( ).

*          lo_json_builder->begin_object( ).
*
*          " SettlementID
*          lo_json_builder->add_member( 'SettlementID' )->add_string( '123456' ).
*
*          " SettlementDate
*          lo_json_builder->add_member( 'SettlementDate' )->add_string( '10.01.2024' ).
*
*          " SettlementRecieverDetails
*          lo_json_builder->add_member( 'SettlementRecieverDetails' )->begin_object( ).
**          lo_json_builder->add_member( 'FullName' )->add_string( 'VÝCHOR s.r.o.' ).
*          lo_json_builder->add_member( 'FullName' )->add_string( <lfs_bp>-customerfullname ).
*          lo_json_builder->add_member( 'Address' )->begin_object( ).
**          lo_json_builder->add_member( 'City' )->add_string( 'Chlmec' ).
*          lo_json_builder->add_member( 'City' )->add_string( <lfs_bp>-cityname ).
*          lo_json_builder->add_member( 'Street' )->add_string( 'Chlmec' ).
*          lo_json_builder->add_member( 'HouseNumber' )->add_string( '77' ).
*          lo_json_builder->add_member( 'PostalCode' )->add_string( '06741' ).
*          lo_json_builder->end_object( ).
*          lo_json_builder->add_member( 'Email' )->add_string( 'cpimailpoc@gmail.com' ).
*          lo_json_builder->add_member( 'TAXIDs' )->begin_object( ).
*          lo_json_builder->add_member( 'ICO' )->add_string( '47436352' ).
*          lo_json_builder->add_member( 'DIC' )->add_string( '2023919513' ).
*          lo_json_builder->add_member( 'IC_DPH' )->add_string( 'SK2023919513' ).
*          lo_json_builder->end_object( ).
*          lo_json_builder->end_object( ).
*
*          " SettlementItems
*          lo_json_builder->add_member( 'SettlementItems' )->begin_array( ).
*          lo_json_builder->begin_object( ).
*          lo_json_builder->add_member( 'ItemsSent' )->begin_array( ).
*
*          " Loop through and add ItemsSent data
*          lo_json_builder->begin_object( ).
*          lo_json_builder->add_member( 'VS' )->add_string( '713200945' ).
*          lo_json_builder->add_member( 'DueDate' )->add_string( '14.07.2023' ).
*          lo_json_builder->add_member( 'OriginalValue' )->add_string( '1691,50' ).
*          lo_json_builder->add_member( 'SettledClaim' )->add_string( '1691,50' ).
*          lo_json_builder->add_member( 'SettledLiability' )->add_string( '0.0' ).
*          lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
*          lo_json_builder->end_object( ).
*
*          lo_json_builder->begin_object( ).
*          lo_json_builder->add_member( 'VS' )->add_string( '72350892' ).
*          lo_json_builder->add_member( 'DueDate' )->add_string( '14.07.2023' ).
*          lo_json_builder->add_member( 'OriginalValue' )->add_string( '1154,40' ).
*          lo_json_builder->add_member( 'SettledClaim' )->add_string( '1154,40' ).
*          lo_json_builder->add_member( 'SettledLiability' )->add_string( '0.0' ).
*          lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
*          lo_json_builder->end_object( ).
*
*          " Add other ItemsSent objects similarly
*
*          lo_json_builder->end_array( ).
*
*          lo_json_builder->add_member( 'ItemsReceived' )->begin_array( ).
*          lo_json_builder->begin_object( ).
*          lo_json_builder->add_member( 'VS' )->add_string( '2362002007' ).
*          lo_json_builder->add_member( 'DueDate' )->add_string( '14.08.2023' ).
*          lo_json_builder->add_member( 'OriginalValue' )->add_string( '-73587,42' ).
*          lo_json_builder->add_member( 'SettledClaim' )->add_string( '0,00' ).
*          lo_json_builder->add_member( 'SettledLiability' )->add_string( '-5448,76' ).
*          lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
*          lo_json_builder->end_object( ).
*          lo_json_builder->end_array( ).
*          lo_json_builder->end_object( ).
*
*          lo_json_builder->end_array( ).
*
*          " End the JSON object
*          lo_json_builder->end_object( ).
*
*          " Get the JSON string
*          lv_json = lo_json_builder->get_data(  )->to_string( ).

      CATCH cx_root INTO DATA(lx_exception).
        " Handle any exceptions
    ENDTRY.



    rv_request_body = lo_json_builder->get_data( )->to_string(  ).

*{
*    "SettlementID": "123456",
*    "SettlementDate": "10.01.2024",
*    "SettlementRecieverDetails": {
*        "FullName": "VÝCHOR s.r.o.",
*        "Address": {
*            "City": "Chlmec",
*            "Street": "Chlmec",
*            "HouseNumber": "77",
*            "PostalCode": "06741"
*        },
*        "Email": "cpimailpoc@gmail.com",
*        "TAXIDs": {
*            "ICO": "47436352",
*            "DIC": "2023919513",
*            "IC_DPH": "SK2023919513"
*        }
*    },
*    "SettlementItems": [
*        {
*            "ItemsSent": [
*                {
*                    "VS": "713200945",
*                    "DueDate": "14.07.2023",
*                    "OriginalValue": "1691,50",
*                    "SettledClaim": "1691,50",
*                    "SettledLiability": "0.0",
*                    "Balance": "0.0"
*                },
*                {
*                    "VS": "72350892",
*                    "DueDate": "14.07.2023",
*                    "OriginalValue": "1154,40",
*                    "SettledClaim": "1154,40",
*                    "SettledLiability": "0.0",
*                    "Balance": "0.0"
*                },
*                {
*                    "VS": "713200983",
*                    "DueDate": "14.07.2023",
*                    "OriginalValue": "2295,77",
*                    "SettledClaim": "2295,77",
*                    "SettledLiability": "0.0",
*                    "Balance": "0.0"
*                },
*                {
*                    "VS": "72330257",
*                    "DueDate": "14.07.2023",
*                    "OriginalValue": "307,09",
*                    "SettledClaim": "307,09",
*                    "SettledLiability": "0.0",
*                    "Balance": "0.0"
*                }
*            ],
*            "ItemsReceived": [
*                {
*                    "VS": "2362002007",
*                    "DueDate": "14.08.2023",
*                    "OriginalValue": "-73587,42",
*                    "SettledClaim": "0,00",
*                    "SettledLiability": "-5448,76",
*                    "Balance": "0.0"
*                }
*            ]
*        }
*    ]
*}

  ENDMETHOD.


  METHOD fetch_bp_data.

* not allowed
*    SELECT
*    FROM C_businesspartner WITH PRIVILEGED ACCESS
*    FIELDS \_BusinessPartnerAddrFilter-EmailAddress,
*           \_BusinessPartnerTaxNumber-BPTaxType,
*           \_BusinessPartnerTaxNumber-BPTaxNumber
*    WHERE C_businesspartner~BusinessPartner EQ @iv_bp_id
*    INTO TABLE @DATA(lt_bp_data).


*I_BusinessPartnerAddress taky ne

*I_BPEmailAddress - vicero, zadna default

*I_BusinessPartnerAddressTP - not allowed

* fetch address and tax data

    IF iv_is_customer EQ abap_true.

      SELECT
          FROM i_customer WITH PRIVILEGED ACCESS
          FIELDS i_customer~CustomerName,
                 i_customer~streetname,
                 i_customer~cityname,
                 i_customer~postalcode,
*               i_customer~addressid,
                 i_customer~vatregistration,
                 i_customer~taxnumber1,
                 i_customer~taxnumber2
                 WHERE i_customer~customer EQ @iv_bp_id
                 INTO CORRESPONDING FIELDS OF TABLE @ct_bp.

    ELSE.

      SELECT
      FROM i_supplier WITH PRIVILEGED ACCESS
      FIELDS i_supplier~suppliername AS customername,
             i_supplier~streetname,
             i_supplier~cityname,
             i_supplier~postalcode,
*               i_customer~addressid,
             i_supplier~vatregistration,
             i_supplier~taxnumber1,
             i_supplier~taxnumber2
             WHERE i_supplier~supplier EQ @iv_bp_id
             INTO CORRESPONDING FIELDS OF TABLE @ct_bp.

    ENDIF.
* fetch e-mail address




  ENDMETHOD.


  METHOD fetch_settlement_data.

    SELECT *
    FROM i_operationalacctgdocitem WITH PRIVILEGED ACCESS
    WHERE i_operationalacctgdocitem~clearingjournalentry EQ @iv_settlement_id
    INTO CORRESPONDING FIELDS OF TABLE @ct_settlement.

  ENDMETHOD.


  METHOD generate_settlement.

    DATA: lv_is_customer TYPE xsdboolean.

    fetch_settlement_data( EXPORTING iv_settlement_id = io_settlement CHANGING ct_settlement = ct_settlement_data ).

    DATA(bp) = determine_bp( EXPORTING io_settlement_data = ct_settlement_data CHANGING cv_is_customer = lv_is_customer ).

    CHECK bp IS NOT INITIAL.

    fetch_bp_data( EXPORTING iv_bp_id = bp  iv_is_customer = lv_is_customer CHANGING ct_bp = ct_customer_data ).

    CHECK ct_customer_data IS NOT INITIAL.
    CHECK ct_settlement_data IS NOT INITIAL.

    send_settlement_data(
      io_settlement_id   = io_settlement
      io_settlement_data = ct_settlement_data
      io_bp_data         = ct_customer_data
    ).


  ENDMETHOD.


  METHOD if_oo_adt_classrun~main.


    DATA io_settlement TYPE TABLE OF ty_settlement_data_cds.
    DATA bp TYPE ty_settlement_data_cds-customer.


    DATA: lt_unique_customer TYPE TABLE OF ty_settlement_data_cds-customer.
    DATA: lt_unique_supplier TYPE TABLE OF ty_settlement_data_cds-supplier.

    lt_unique_customer = VALUE #( FOR GROUPS value OF <line> IN io_settlement GROUP BY <line>-customer WITHOUT MEMBERS ( value ) ).

*      TRY.
*          generate_settlement( io_settlement = io_settlement ).
*        CATCH cx_web_http_client_error cx_http_dest_provider_error.
*          "handle exception
*      ENDTRY.


  ENDMETHOD.


  METHOD send_settlement_data.

    DATA: lr_cscn TYPE if_com_scenario_factory=>ty_query-cscn_id_range.
    DATA: lo_settlement_data TYPE REF TO ty_settlement_data.
    DATA: lo_bp_data TYPE REF TO ty_bp_data.

* Find CA by Scenario ID
    lr_cscn = VALUE #( ( sign = 'I' option = 'EQ' low = 'ZDPD_SEND_SETTLEMENT' ) ).
    DATA(lo_factory) = cl_com_arrangement_factory=>create_instance( ).
    lo_factory->query_ca(
      EXPORTING
        is_query           = VALUE #( cscn_id_range = lr_cscn )
      IMPORTING
        et_com_arrangement = DATA(lt_ca) ).

    IF lt_ca IS INITIAL.
      EXIT.
    ENDIF.

* take the first one
    READ TABLE lt_ca INTO DATA(lo_ca) INDEX 1.

* get destination based on Communication Arrangement and the service ID
*    try.
    DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
        comm_scenario  = 'ZDPD_SEND_SETTLEMENT'
        service_id     = 'ZDPD_SEND_SETTLEMENT_REST'
        comm_system_id = lo_ca->get_comm_system_id( ) ).

    DATA(http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).
    DATA(request) = http_client->get_http_request( ).

    DATA(json_body) = compose_request_body(
                        io_settlement_id   = io_settlement_id
                        io_settlement_data = io_settlement_data
                        io_bp_data         = io_bp_data
                      ).

    request->set_text( i_text = json_body
                       i_length = strlen( json_body ) ).

    DATA(response) = http_client->execute( if_web_http_client=>get ).
    DATA(result) = response->get_text( ).
*      catch cx_http_dest_provider_error into data(lx_http_dest_provider_error).
*        out->write( lx_http_dest_provider_error->get_text( ) ).
*        exit.
*    endtry.


  ENDMETHOD.


  METHOD determine_bp.

    DATA: lt_unique_customer TYPE TABLE OF ty_settlement_data_cds-customer.
    DATA: lt_unique_supplier TYPE TABLE OF ty_settlement_data_cds-supplier.
    DATA: ls_bp TYPE ty_settlement_data_cds.
    DATA: lv_bp TYPE ty_settlement_data_cds-customer.

* get unique values for Customer
    lt_unique_customer = VALUE #( FOR GROUPS valuec OF <line> IN io_settlement_data GROUP BY <line>-customer WITHOUT MEMBERS ( valuec ) ).
* get unique values for Supplier
    lt_unique_supplier = VALUE #( FOR GROUPS values OF <line> IN io_settlement_data GROUP BY <line>-supplier WITHOUT MEMBERS ( values ) ).

    DATA(lv_unique_customers) = lines( lt_unique_customer ).
    DATA(lv_unique_suppliers) = lines( lt_unique_supplier ).

    CHECK lv_unique_customers <= 1.
    CHECK lv_unique_suppliers <= 1.

    IF lv_unique_customers > 1.
      READ TABLE lt_unique_customer INTO DATA(ls_bp_cust) INDEX 1.
      lv_bp = ls_bp_cust.
      cv_is_customer = abap_true.
    ELSE.
      READ TABLE lt_unique_supplier INTO DATA(ls_bp_supp) INDEX 1.
      lv_bp = ls_bp_supp.
      cv_is_customer = abap_false.
    ENDIF.

    rv_bp = lv_bp.

  ENDMETHOD.

ENDCLASS.
