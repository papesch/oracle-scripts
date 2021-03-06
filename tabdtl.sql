      SET AUTOTRACE OFF
      SET TIMING OFF
      COLUMN COMMENTS FORMAT A50
      COLUMN column_name FORMAT A35
      COLUMN Data_Type FORMAT A15
      COLUMN DATA_DEFAULT FORMAT A20
      COLUMN "PK Column" FORMAT A35
      COLUMN "FK Column" FORMAT A20

      UNDEF Owner
      --ACCEPT Owner PROMPT 'Enter Owner :'
      DEFINE Owner = '&1'

      UNDEF Table_Name
      --ACCEPT Table_Name PROMPT 'Enter Table Name :'
      DEFINE Table_Name = '&2'


      SET HEADING OFF

      PROMPT
      PROMPT Comments for Table &Table_Name.
      SELECT COMMENTS
      FROM ALL_TAB_COMMENTS
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND Owner = UPPER('&Owner.') ;

      SET HEADING ON

      PROMPT
      PROMPT Column Details for Table &Table_Name.

      --Robs tweaks--
      column column_id format 9999999999;
      column column_name format A20 wrapped;
      column data_length format 9999999999;
      column comments format A30 wrapped;
      ---------------

      SELECT
      ROWNUM as "Column_id", T.COLUMN_NAME , T.Data_Type , T.DATA_LENGTH,
      DECODE(T.Nullable, 'N' , 'NOT NULL' , 'Y', ' ') NULLABLE , T.Data_Default , C.Comments
      FROM
      ALL_TAB_COLS T , All_Col_Comments C
      WHERE
      T.OWNER = C.OWNER
      AND T.TABLE_NAME = C.TABLE_NAME
      AND T.COLUMN_NAME = C.COLUMN_NAME
      AND T.TABLE_NAME = UPPER('&Table_Name.')
      AND T.Owner = UPPER('&Owner.') ;


      PROMPT
      PROMPT PRIMARY KEY for Table &Table_Name.

      select COLUMN_NAME
      FROM ALL_CONS_COLUMNS
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND Owner = UPPER('&Owner.')
      AND CONSTRAINT_NAME = ( SELECT CONSTRAINT_NAME
      FROM ALL_CONSTRAINTS
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND CONSTRAINT_TYPE = 'P'
      AND Owner = UPPER('&Owner.')
      )
      ORDER BY POSITION
      /

      PROMPT
      PROMPT INDEXES for Table &Table_Name.
      --Robs tweaks--
      column uniqueness format A10 wrapped;

      BREAK ON INDEX_NAME ON UNIQUENESS SKIP 1

      SELECT I.INDEX_NAME , C.COLUMN_NAME , I.UNIQUENESS
      FROM ALL_IND_COLUMNS C , ALL_INDEXES I
      WHERE C.INDEX_NAME = I.INDEX_NAME
      AND C.TABLE_NAME = I.TABLE_NAME
      AND I.TABLE_NAME = UPPER('&Table_Name.')
      AND I.Owner = UPPER('&Owner.')
      AND C.Table_Owner = UPPER('&Owner.')
      AND NOT EXISTS ( SELECT 'X'
      FROM ALL_CONSTRAINTS
      WHERE CONSTRAINT_NAME = I.INDEX_NAME
      AND Owner = UPPER('&Owner.')
      )
      ORDER BY INDEX_NAME , COLUMN_POSITION
      /

      CLEAR BREAKS

      PROMPT
      PROMPT FOREIGN KEYS for Table &Table_Name.

      BREAK ON CONSTRAINT_NAME ON TABLE_NAME ON R_CONSTRAINT_NAME SKIP 1
      COLUMN POSITION NOPRINT

      SELECT UNIQUE A.CONSTRAINT_NAME,
      C.COLUMN_NAME "FK Column" ,
      B.TABLE_NAME || '.' || B.COLUMN_NAME "PK Column",
      A.R_CONSTRAINT_NAME ,
      C.POSITION
      FROM ALL_CONSTRAINTS A, ALL_CONS_COLUMNS B, ALL_CONS_COLUMNS C
      WHERE A.R_CONSTRAINT_NAME=B.CONSTRAINT_NAME
      AND B.OWNER=UPPER('&OWNER')
      AND A.CONSTRAINT_NAME=C.CONSTRAINT_NAME
      AND A.OWNER=C.OWNER
      AND A.OWNER = B.OWNER
      AND A.TABLE_NAME=C.TABLE_NAME
      AND B.POSITION=C.POSITION
      AND A.TABLE_NAME LIKE UPPER('&TABLE_NAME')
      ORDER BY A.CONSTRAINT_NAME, C.POSITION
      /

      COLUMN POSITION NOPRINT
      CLEAR BREAKS

      PROMPT
      PROMPT CONSTRAINTS for Table &Table_Name.

      SELECT CONSTRAINT_NAME , SEARCH_CONDITION
      FROM ALL_CONSTRAINTS
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND Owner = UPPER('&Owner.')
      AND CONSTRAINT_TYPE NOT IN ( 'P' , 'R');

      PROMPT
      PROMPT ROWCOUNT for Table &Table_Name.

      SET FEEDBACK OFF
      SET SERVEROUTPUT ON
      DECLARE N NUMBER ;
      V VARCHAR2(100) ;
      BEGIN
      V := 'SELECT COUNT(*) FROM ' || UPPER('&Table_Name.') ;
      EXECUTE IMMEDIATE V INTO N ;
      DBMS_OUTPUT.PUT_LINE (N);
      END;
      /

      SET FEEDBACK ON

      PROMPT
      PROMPT Tables That REFER to Table &Table_Name.

      BREAK ON TABLE_NAME ON CONSTRAINT_NAME skip 1

      SELECT C.TABLE_NAME , C.CONSTRAINT_Name , CC.COLUMN_NAME "FK Column"
      FROM ALL_CONSTRAINTS C
      , All_Cons_colUMNs CC
      WHERE C.Constraint_Name = CC.Constraint_Name
      AND R_CONSTRAINT_NAME = ( SELECT CONSTRAINT_NAME
      FROM ALL_CONSTRAINTS
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND CONSTRAINT_TYPE = 'P'
      AND Owner = UPPER('&Owner.')
      )
      AND C.Owner = UPPER('&Owner.')
      /

      CLEAR BREAKS


      PROMPT
      PROMPT PARTITIONED COLUMNS for Table &Table_Name.

      SELECT COLUMN_NAME , COLUMN_POSITION
      FROM All_Part_Key_Columns
      WHERE NAME = UPPER('&Table_Name.')
      AND Owner = UPPER('&Owner.') ;


      PROMPT
      PROMPT PARTITIONS for Table &Table_Name.

      SELECT PARTITION_NAME , NUM_ROWS
      FROM All_Tab_Partitions
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND Table_Owner = UPPER('&Owner.') ;


      PROMPT
      PROMPT TRIGGERS for Table &Table_Name.

      SELECT Trigger_Name
      FROM All_Triggers
      WHERE TABLE_NAME = UPPER('&Table_Name.')
      AND Owner = UPPER('&Owner.') ;

      PROMPT
      PROMPT DEPENDANTS for Table &Table_Name.

      BREAK ON TYPE SKIP 1

      SELECT TYPE , NAME
      FROM ALL_DEPENDENCIES
      WHERE REFERENCED_NAME = UPPER('&Table_Name.')
      ORDER BY TYPE ;

      CLEAR BREAKS

      SET TERMOUT OFF
      SET AUTOTRACE ON
      SET TIMING ON
      SET TERMOUT ON

      EXIT
