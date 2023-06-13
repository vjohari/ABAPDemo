*&---------------------------------------------------------------------*
*& Report Z_DYNCI
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_DYNCI.

PARAMETERS: p_str TYPE string.
DATA: home TYPE string.
DATA: cmd TYPE string.

CALL FUNCTION 'REGISTRY_GET'
  EXPORTING
     KEY   = 'APPHOME'
  IMPORTING
     VALUE = home.

CONCATENATE home p_str INTO cmd.
CALL 'SYSTEM' ID 'COMMAND' FIELD cmd.
