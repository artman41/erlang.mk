Old Erlang.mk documentation
===========================

This documentation reminds here until it gets moved to the
official documentation on http://erlang.mk/guide/.

ErlyDTL plugin
--------------

This plugin is available by default. It adds automatic
compilation of ErlyDTL templates found in `templates/*.dtl`
or any subdirectory. 

By default it ignores names of subdirectories and compiles 
`a/b/templatename.dtl` into `templatename_dtl.beam`. To include 
subdirectories names in the compiled module name add 
`DTL_FULL_PATH=1` into your Makefile - `a/b/templatename.dtl`
will be compiled into `a_b_templatename_dtl.beam`.

Additional ErlyDTL options can be specified as a comma-separated list
by defining the `DTL_OPTS` variable. Those options will be prepended
to the options specified by the plugin itself.
