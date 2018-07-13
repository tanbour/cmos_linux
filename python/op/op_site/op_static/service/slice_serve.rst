.. _slice_serve:

Slice_serve - Q & A 
======================

1. **Variable in config un-align**

**[Question]** If variables in config are not align, value will not correctly apply.

Example:

a = 1
 b = 2

then a = [1 , b=2] 

If "a" and "b" are both align by starting with a space, then it’s OK.

Example: 
 a =1 
 b= 2

then a = 1

**[Answer]** 

config rule require variables need to be aligned, this is Pyhton config paser required.


2. **Block information not shown in WEB.**

**[Question]** They have a block named “pengine”, they have try run with OP, but not show any information in WEB.

**[Answer]** user soruce <sub_stage>.op.run in terminal instead of "op flow -run", run information will not been record in database.
