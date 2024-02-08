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
             bp_id   TYPE string,
             bp_mail TYPE string,
             bp_name TYPE string,
           END OF ty_bp_data.

    CLASS-METHODS:

      generate_settlement
        IMPORTING
          !io_settlement_data TYPE REF TO ty_settlement_data.

            INTERFACES if_oo_adt_classrun .

  PROTECTED SECTION.

  PRIVATE SECTION.

    CLASS-METHODS:
      fetch_settlement_data
        IMPORTING
          iv_settlement_id          TYPE string
        RETURNING
          VALUE(rv_settlement_data) TYPE REF TO ty_settlement_data,

      fetch_bp_data
        IMPORTING
          iv_bp_id          TYPE string
        RETURNING
          VALUE(rv_bp_data) TYPE REF TO ty_bp_data,

      send_settlement_data
        IMPORTING
          io_settlement_data TYPE REF TO ty_settlement_data
          io_bp_data         TYPE REF TO ty_bp_data,

      compose_request_body
        IMPORTING
            io_settlement_data TYPE REF TO ty_settlement_data
            io_bp_data         TYPE REF TO ty_bp_data
         RETURNING
            VALUE(rv_request_body) TYPE string.

ENDCLASS.



CLASS zcl_settlement IMPLEMENTATION.


  METHOD fetch_bp_data.

  ENDMETHOD.

  METHOD fetch_settlement_data.

  ENDMETHOD.

  METHOD generate_settlement.

    DATA(bp_data) = fetch_bp_data( iv_bp_id = io_settlement_data->customer ).
    DATA(settlement_data) = fetch_settlement_data( iv_settlement_id = io_settlement_data->settlement_id ).

    send_settlement_data(
      io_settlement_data = settlement_data
      io_bp_data         = bp_data
    ).


  ENDMETHOD.

  METHOD send_settlement_data.

    "TRY.
        DATA(lo_dest) = cl_http_destination_provider=>create_by_comm_arrangement(
            comm_scenario  = 'YY1_SEND_SETTLEMENT'
            service_id     = 'YY1_SETTLEMENT_REST'
          ).

        DATA(lo_http_client) = cl_web_http_client_manager=>create_by_http_destination( lo_dest ).

        " execute the request
        DATA(lo_request) = lo_http_client->get_http_request( ).
        DATA(lo_response) = lo_http_client->execute( if_web_http_client=>get ).

      "CATCH cx_http_dest_provider_error.
        " handle exception here

      "CATCH cx_web_http_client_error.
        " handle exception here
    "ENDTRY.


  ENDMETHOD.

  METHOD if_oo_adt_classrun~main.

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
                        io_settlement_data = lo_settlement_data
                        io_bp_data         = lo_bp_data
                      ).

    request->set_text( i_text = CONV #( json_body )
                       i_length = strlen( json_body ) ).

    DATA(response) = http_client->execute( if_web_http_client=>get ).
    DATA(result) = response->get_text( ).
*      catch cx_http_dest_provider_error into data(lx_http_dest_provider_error).
*        out->write( lx_http_dest_provider_error->get_text( ) ).
*        exit.
*    endtry.

  ENDMETHOD.

  METHOD compose_request_body.

    DATA: lv_json TYPE string.

    DATA(lo_json_builder) = xco_cp_json=>data->builder( ).

    TRY.
        " Start building the JSON object
        lo_json_builder->begin_object( ).

        " SettlementID
        lo_json_builder->add_member( 'SettlementID' )->add_string( '123456' ).

        " SettlementDate
        lo_json_builder->add_member( 'SettlementDate' )->add_string( '10.01.2024' ).

        " SettlementRecieverDetails
        lo_json_builder->add_member( 'SettlementRecieverDetails' )->begin_object( ).
        lo_json_builder->add_member( 'FullName' )->add_string( 'VÝCHOR s.r.o.' ).
        lo_json_builder->add_member( 'Address' )->begin_object( ).
        lo_json_builder->add_member( 'City' )->add_string( 'Chlmec' ).
        lo_json_builder->add_member( 'Street' )->add_string( 'Chlmec' ).
        lo_json_builder->add_member( 'HouseNumber' )->add_string( '77' ).
        lo_json_builder->add_member( 'PostalCode' )->add_string( '06741' ).
        lo_json_builder->end_object( ).
        lo_json_builder->add_member( 'Email' )->add_string( 'cpimailpoc@gmail.com' ).
        lo_json_builder->add_member( 'TAXIDs' )->begin_object( ).
        lo_json_builder->add_member( 'ICO' )->add_string( '47436352' ).
        lo_json_builder->add_member( 'DIC' )->add_string( '2023919513' ).
        lo_json_builder->add_member( 'IC_DPH' )->add_string( 'SK2023919513' ).
        lo_json_builder->end_object( ).
        lo_json_builder->end_object( ).

        " SettlementItems
        lo_json_builder->add_member( 'SettlementItems' )->begin_array( ).
        lo_json_builder->begin_object( ).
        lo_json_builder->add_member( 'ItemsSent' )->begin_array( ).

        " Loop through and add ItemsSent data
        lo_json_builder->begin_object( ).
        lo_json_builder->add_member( 'VS' )->add_string( '713200945' ).
        lo_json_builder->add_member( 'DueDate' )->add_string( '14.07.2023' ).
        lo_json_builder->add_member( 'OriginalValue' )->add_string( '1691,50' ).
        lo_json_builder->add_member( 'SettledClaim' )->add_string( '1691,50' ).
        lo_json_builder->add_member( 'SettledLiability' )->add_string( '0.0' ).
        lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
        lo_json_builder->end_object( ).

        lo_json_builder->begin_object( ).
        lo_json_builder->add_member( 'VS' )->add_string( '72350892' ).
        lo_json_builder->add_member( 'DueDate' )->add_string( '14.07.2023' ).
        lo_json_builder->add_member( 'OriginalValue' )->add_string( '1154,40' ).
        lo_json_builder->add_member( 'SettledClaim' )->add_string( '1154,40' ).
        lo_json_builder->add_member( 'SettledLiability' )->add_string( '0.0' ).
        lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
        lo_json_builder->end_object( ).

        " Add other ItemsSent objects similarly

        lo_json_builder->end_array( ).

        lo_json_builder->add_member( 'ItemsReceived' )->begin_array( ).
        lo_json_builder->begin_object( ).
        lo_json_builder->add_member( 'VS' )->add_string( '2362002007' ).
        lo_json_builder->add_member( 'DueDate' )->add_string( '14.08.2023' ).
        lo_json_builder->add_member( 'OriginalValue' )->add_string( '-73587,42' ).
        lo_json_builder->add_member( 'SettledClaim' )->add_string( '0,00' ).
        lo_json_builder->add_member( 'SettledLiability' )->add_string( '-5448,76' ).
        lo_json_builder->add_member( 'Balance' )->add_string( '0.0' ).
        lo_json_builder->end_object( ).
        lo_json_builder->end_array( ).
        lo_json_builder->end_object( ).

        lo_json_builder->end_array( ).

        " End the JSON object
        lo_json_builder->end_object( ).

        " Get the JSON string
        lv_json = lo_json_builder->get_data(  )->to_string( ).

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

ENDCLASS.
