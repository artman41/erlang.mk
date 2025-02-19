# Sphinx plugin.

# Disable this test suite when sphinx is not installed.
ifeq ($(shell which sphinx-build),)
sphinx_TARGETS =
else
sphinx_TARGETS = $(call list_targets,sphinx)
endif

.PHONY: sphinx $(sphinx_TARGETS)

sphinx: $(sphinx_TARGETS)

sphinx-build: init

	$i "Bootstrap a new OTP application named $(APP)"
	$t mkdir $(APP)/
	$t cp ../erlang.mk $(APP)/
	$t $(MAKE) -C $(APP) -f erlang.mk bootstrap $v

	$i "Generate Sphinx config"
	$(call sphinx-generate-doc-skeleton)

	$i "Run Sphinx"
	$t $(MAKE) -C $(APP) sphinx $v

	$i "Check that documentation was generated"
	$t test -f $(APP)/html/index.html
	$t test -f $(APP)/html/manpage.html

	$i "Distclean the application"
	$t $(MAKE) -C $(APP) distclean $v

	$i "Check that the generated documentation was removed"
	$t test ! -e $(APP)/html/index.html
	$t test ! -e $(APP)/html/manpage.html

	$i "Set 'today' macro with command-line options"
	$t echo "SPHINX_OPTS = -D 'today=erlang_mk_sphinx_today'" >> $(APP)/Makefile

	$i "Run Sphinx"
	$t $(MAKE) -C $(APP) sphinx $v

	$i "Check that the 'today' macro was defined"
	$t grep -q erlang_mk_sphinx_today $(APP)/html/manpage.html

sphinx-source-dir: init

	$i "Bootstrap a new OTP application named $(APP)"
	$t mkdir $(APP)/
	$t cp ../erlang.mk $(APP)/
	$t $(MAKE) -C $(APP) -f erlang.mk bootstrap $v

	$i "Change documentation source directory"
	$t echo "SPHINX_SOURCE = documentation" >> $(APP)/Makefile

	$i "Generate Sphinx config"
	$(call sphinx-generate-doc-skeleton,documentation)

	$i "Run Sphinx (html)"
	$t $(MAKE) -C $(APP) sphinx $v

	$i "Check that documentation was generated"
	$t test -f $(APP)/html/index.html
	$t test -f $(APP)/html/manpage.html

sphinx-formats: init

	$i "Bootstrap a new OTP application named $(APP)"
	$t mkdir $(APP)/
	$t cp ../erlang.mk $(APP)/
	$t $(MAKE) -C $(APP) -f erlang.mk bootstrap $v

	$i "Define formats generated by Sphinx"
	$t echo "SPHINX_FORMATS = html man" >> $(APP)/Makefile

	$i "Generate Sphinx config"
	$(call sphinx-generate-doc-skeleton)

	$i "Run Sphinx (html + man)"
	$t $(MAKE) -C $(APP) sphinx $v

	$i "Check that documentation was generated"
	$t test -f $(APP)/man/sphinx_$(APP).1
	$t test -f $(APP)/html/index.html
	$t test -f $(APP)/html/manpage.html

	$i "Distclean the application"
	$t $(MAKE) -C $(APP) distclean $v

	$i "Check that the generated documentation was removed"
	$t test ! -e $(APP)/man/sphinx_$(APP).1
	$t test ! -e $(APP)/html/index.html
	$t test ! -e $(APP)/html/manpage.html

	$i "Change documentation output directories"
	$t echo "sphinx_html_output = sphinx/html_output" >> $(APP)/Makefile
	$t echo "sphinx_man_output  = sphinx/man_output"  >> $(APP)/Makefile

	$i "Run Sphinx (html + man)"
	$t $(MAKE) -C $(APP) sphinx $v

	$i "Check that documentation was generated"
	$t test -f $(APP)/sphinx/man_output/sphinx_$(APP).1
	$t test -f $(APP)/sphinx/html_output/index.html
	$t test -f $(APP)/sphinx/html_output/manpage.html

	$i "Distclean the application"
	$t $(MAKE) -C $(APP) distclean $v

	$i "Check that the generated documentation was removed"
	$t test ! -e $(APP)/sphinx/man_output/sphinx_$(APP).1
	$t test ! -e $(APP)/sphinx/html_output/index.html
	$t test ! -e $(APP)/sphinx/html_output/manpage.html

sphinx-format-opts: init

	$i "Bootstrap a new OTP application named $(APP)"
	$t mkdir $(APP)/
	$t cp ../erlang.mk $(APP)/
	$t $(MAKE) -C $(APP) -f erlang.mk bootstrap $v

	$i "Define formats generated by Sphinx"
	$t echo "SPHINX_FORMATS = html man" >> $(APP)/Makefile

	$i "Change format-specific options"
	$t echo "sphinx_html_opts = -D 'today=erlang_mk_sphinx_html_today'" >> $(APP)/Makefile
	$t echo "sphinx_man_opts  = -D 'today=erlang_mk_sphinx_man_today'"  >> $(APP)/Makefile

	$i "Generate Sphinx config"
	$(call sphinx-generate-doc-skeleton)

	$i "Run Sphinx (html + man)"
	$t $(MAKE) -C $(APP) sphinx $v

	$i "Check that the 'today' macro was defined correctly"
	$t grep -q erlang_mk_sphinx_html_today $(APP)/html/manpage.html
	$t grep -q erlang_mk_sphinx_man_today $(APP)/man/sphinx_$(APP).1

define sphinx-generate-doc-skeleton
$t mkdir $(APP)/$(if $1,$1,doc)/
$t printf "%s\n" \
	"project = '$(APP)'" \
	"master_doc = 'index'" \
	"source_suffix = '.rst'" \
	"man_pages = [('manpage', 'sphinx_$(APP)', 'Man Page', [], 1)]" \
	"" > $(APP)/$(if $1,$1,doc)/conf.py

$t printf "%s\n" \
	"***********" \
	"Sphinx Docs" \
	"***********" \
	"" \
	"ToC" \
	"===" \
	"" \
	".. toctree::" \
	"" \
	"   manpage" \
	"" \
	"Indices" \
	"=======" \
	"" \
	'* :ref:`genindex`' \
	'* :ref:`modindex`' \
	'* :ref:`search`' \
	"" > $(APP)/$(if $1,$1,doc)/index.rst

$t printf "%s\n" \
	"********" \
	"Man Page" \
	"********" \
	"" \
	"Synopsis" \
	"========" \
	"" \
	".. code-block:: none" \
	"" \
	"    erlang-sphinx-mk-man [--help]" \
	"" \
	"today = |today|" \
	"" > $(APP)/$(if $1,$1,doc)/manpage.rst
endef
