CLASS lhc_z_ddl_settlement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

*    METHODS get_instance_features FOR INSTANCE FEATURES
*      IMPORTING keys REQUEST requested_features FOR z_ddl_settlement RESULT result.

    "Metoda nastavuje ACTION volbu POTVRDIT na aktivne/neaktivne
    METHODS get_features FOR FEATURES
          IMPORTING keys REQUEST requested_features FOR Settl RESULT result.


    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Settl RESULT result.

*    METHODS create FOR MODIFY
*      IMPORTING entities FOR CREATE Settl.

*    METHODS update FOR MODIFY
*      IMPORTING entities FOR UPDATE Settl.

*    METHODS delete FOR MODIFY
*      IMPORTING keys FOR DELETE Settl.

    METHODS read FOR READ
      IMPORTING keys FOR READ Settl RESULT result.

    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK Settl.

    METHODS acceptnext FOR MODIFY
      IMPORTING keys FOR ACTION Settl~acceptnext RESULT result.

ENDCLASS.

CLASS lhc_z_ddl_settlement IMPLEMENTATION.

*  METHOD get_instance_features.
*  ENDMETHOD.

 METHOD get_features.
    " Read the travel status of the existing travels
    READ ENTITIES OF Z_DDL_SETTLEMENT IN LOCAL MODE
      ENTITY Settl
        FIELDS ( AccountingDocument ) WITH CORRESPONDING #( keys )
      RESULT DATA(udaje)
      FAILED failed.

    result =
      VALUE #(
        FOR udaj IN udaje
          LET is_accepted =   if_abap_behv=>fc-o-enabled
              is_rejected =   if_abap_behv=>fc-o-disabled
          IN
            ( %tky                 = udaj-%tky
              %action-acceptNext = is_accepted
             ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

*  METHOD create.
*  ENDMETHOD.

*  METHOD update.
*  ENDMETHOD.

*  METHOD delete.
*  ENDMETHOD.

  METHOD read.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD acceptnext.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_key>).

      TRY.

          zcl_settlement=>generate_settlement( io_settlement = <lfs_key>-accountingdocument ).

        CATCH cx_web_http_client_error.
        CATCH cx_http_dest_provider_error.
      ENDTRY.

    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_z_ddl_settlement DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.

    METHODS finalize REDEFINITION.

    METHODS check_before_save REDEFINITION.

    METHODS save REDEFINITION.

    METHODS cleanup REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_z_ddl_settlement IMPLEMENTATION.

  METHOD finalize.
  ENDMETHOD.

  METHOD check_before_save.
  ENDMETHOD.

  METHOD save.
  ENDMETHOD.

  METHOD cleanup.
  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
