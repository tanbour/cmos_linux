.. _flat_serve:

Flat_serve - Feature update recored 
=========================================

OP runner
-----------------------------------------

1. Job queue detection

   + Function: detect job queue "_job_queue" exist before submit job.

2. User authorization

   + Function: detect user privilege in queue "_job_queue".

3. flow subcmd -yes option

   + Function: new -yes option to answer all stdin prompt hint (yes or no)
   + Used for batch op operation or script integration

4. init subcmd -b option

   + Function: new -b option to show only wished blocks locally
   + Used clean up the user workspace directories

OP web
-----------------------------------------

1. Web SPA (Single Page Application) url

   + Function: added url router support for each separated abstract page.
   + Convenient to deliver the url address directly to go through the application
