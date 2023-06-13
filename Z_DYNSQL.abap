*&---------------------------------------------------------------------*
*& Report Z_DYNSQL
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT Z_DYNSQL.

PARAMETERS: p_str TYPE string.
DATA: sql TYPE REF TO cl_sql_statement.

CALL METHOD sql->execute_ddl
  EXPORTING
    statement = p_str.
