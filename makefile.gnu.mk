# GNU Makefile 
##  GMakefile-std-lib-foo
##  vim: set ft=make sw=2 ts=4: 
THIS_MAKEFILE := $(firstword $(MAKEFILE_LIST))

PROGRAM = testargv
CODE := $(CURDIR)/code/
PROGRAM_FILES = testinput.cc
_CODEF := $(wildcard $(CODE)*.cc)
_CODEF ||= None
LIB_Called_WHAT =

# pkg-config fudging - help get glib, glibmm from kludgy pkgconfig.
#-# It is in /usr/lib/i386-linux-gnu/pkgconfig/

# remember, "export" is for sub-makes that are started. This is not an sh shell!
export PKG_CONFIG_PATH := $(if ${PKG_CONFIG_PATH},$(PKG_CONFIG_PATH):/usr/lib/i386-linux-gnu/pkgconfig,/usr/lib/i386-linux-gnu/pkgconfig)
# pkgconfig_aliases := $(/usr/bin/pkg-config --list-all |egrep glib.\\*2\\.\d)
# pkg-config garbage boilerplate
_PCLOl := --libs-only-l
_PCLOL := --libs-only-L
_PCCOO := --cflags-only-other

_BP = _PCLOl _PCLOL _PCCOO
BP  =  $(PCLOL) $(PCLOl) $(PCCOO)

define BPARAMS
$(eval $(3) = $$(shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config $(1) $(2) 2>/dev/null || echo -n "Failed to get $(1)"))
endef


glibmm_ = glibmm
glib_   = glib

HD_PPINCL =
HD_PPDEFS := -DUNICODE
HD_CCOPT_CCMACH:= -ansi -pipe -O0 -momit-leaf-frame-pointer -march=i686 -funsigned-char 

CFLAGS	+= -g
ifeq ($(origin LDFLAGS),automatic)
LDFLAGS	:= -g
else
LDFLAGS	+= -g
endif

ECHO ?= echo

# colors: 0-7 and sgr0 to get normal
define _f_printf_colors
$(eval COLR$$(1) := $(shell tput setaf $(1)))
endef
pf := $(shell which printf || printf >/dev/stderr "Failed to find printf")
_ := $(foreach C,0 1 2 3 4 5 6 7 sgr0,$(call _f_printf_colors,$(C)))
smso := $(shell tput smso)
rmso := $(shell tput rmso)
define _pc_
/usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) /usr/bin/pkg-config --list-all |sed -n s'^\(glibmm-\S\S*\)\s.*^\1^p'
endef

define _fTry
$(shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags $(1) 1>/dev/null 2>&1|| echo -n "None")
endef
define _fReal
$(shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --cflags $(1) 2>/dev/null || echo -n "None")
endef
## $(shell echo -n "-L/usr/lib/i386-linux-gnu")
define _fLDf
$(if ${strip $(call _fpc_get, $(glibmm_),--print-errors --short-errors --errors-to-stdout --libs)},$(call _fpc_get, $(glibmm_),--print-errors --short-errors --errors-to-stdout --libs),NO_LD_L)
endef
define _fpc_get
$(shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config $(2) $(1) || echo -n "None")
endef


define _fIsGcc
$(if $(findstring gcc,$(CC)$(cc)$(GCC)$(gcc))$(findstring gxx,$(c++)), Success,None)
endef

define _fNotEmpty
$(if $(filter $(strip $(1)),$(2)),$(1),None)
endef
define _fOneSpace
$(NADA) $(NADA)
endef
define _fNull
$(NADA)$(NADA)
endef
define _fEqNone
$(strip $(firstword $(1)))
endef
define _fMatch
$(if $(filter $(1),$(2)),$(_fNull),$(1))
endef
define _fGet
$(shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --modversion $(1))
endef
define _fIN
STR1 = $(1)
LONGSTR= $(2)
$(if $(foreach $(STR1),$(filter $(STR1),$(LONGSTR)),True,False)
endef

define f_QuoteMe
$(if $(strip $($(1))),"$(strip $($(1)))")
endef

define assCtoO
$(CXX) -o build/$(notdir $(1)) $(HD_CCOPT_CCMACH) $(PCCOO) $(HD_PPDEFS) $(HD_PPFLAGS) $(foreach IN,$(HD_PPINCL),$(call f_QuoteMe,IN)) $(if $2,$(addprefix -c ,$2))
endef

define lnkOtoE
$(CXX) -o build/$(notdir $(1))
endef

TEST = $(shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --modversion $(glibmm_))
RESULT = $(foreach V,$(TEST),$(call _fIN,$(V)))

# shell /usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) pkg-config --modversion $(glib))
LIB_Called_WHAT = $(call _fEqNone,$(call _fMatch,$(call _fTry,$(glibmm_))))

define _enum_
"$(glib_)"  "$(glibmm_)"
"$(CC)"
"$(HD_PPINCL)"
"$(HD_PPDEFS)"
"$(HD_PPFLAGS)"
"$(PCLOL)"
"$(PCLOl)"
"$(PC_IOO)"
endef
define _penum_
HD_PPINCL
HD_PPDEFS
HD_PPFLAGS
PC_IOO
endef

define f_SplitDict
$(foreach YA,$(1),$(if ${$(YA)},$(call join,$(YA)|,${$(YA)})))
endef
define LONGLINE
'Building $(COLR2)%s$(COLRsgr0)$(COLR7) to satisfy $(COLRsgr0)$(COLR3)%s$(COLRsgr0)$(COLR7):\n' '$(PROGRAM)' '$@'

endef

build: prebuild object $(PROGRAM)
	@$(ECHO) Done.



# ------------ *** ----------- #
ifneq (${LIB_Called_WHAT},None)
# ------------ *** ----------- #
pkgconfigcheck:
	@echo pkgconfig worked without probing for $(LIB_Called_WHAT)

pkgconfigx: pkgconfigcheck 
	@/usr/bin/env PKG_CONFIG_PATH=$(PKG_CONFIG_PATH) /usr/bin/pkg-config --cflags-only-I $(glibmm_)
	@>/dev/stderr $(pf) "$(COLR0)Our GCC preprocessor flags: $(COLRsgr0)$(COLR5)%s$(COLRsgr0)\n" '$(HD_PPINCL)'
# ------------ *** ----------- #
else
# ------------ *** ----------- #
_FOO_ := $(warning Glibmm is not "glibmm" but might be $(glibmm_)-*.*)
glibmm_ = glibmm-2.4
glib_   = glib-2.4
LIB_Called_WHAT = $(if $(patsubst YES%,YES$(glibmm_),$(call _fEqNone,$(call _fMatch,$(call _fGet,$(glibmm_))))),$(glibmm_),None)
YO := $(warning Discovered lglibmm as $(LIB_Called_WHAT))

HD_PPINCL = $(call _fReal,$(glibmm_))
HD_PPINCL := $(patsubst -I%,-isystem%,$(HD_PPINCL))
pkgconfigcheck:
	@>/dev/stderr $(pf) '\nPKG_CONFIG_PATH from %s is set to $(PKG_CONFIG_PATH)\n'  \
    "$(if $(filter file,$(origin PKG_CONFIG_PATH)),Makefile,$(origin PKG_CONFIG_PATH))"
	@>/dev/stderr $(pf) '\tLooking for lib called %s -- found: %s\n' '$(glibmm_)' '$(LIB_Called_WHAT)'
	@>/dev/null $(_pc_)

pkgconfigx: pkgconfigcheck 
	@>/dev/stderr $(pf) "\n$(COLR1)Our GCC preprocessor flags:$(COLRsgr0)\n"
	@>/dev/stderr $(pf) "$(COLRsgr0)$(COLR4)%s$(COLRsgr0)$(COLR7)\n" '$(HD_PPINCL)'
# ------------ *** ----------- #
endif
# ------------ *** ----------- #


ifeq ($(CXX),)
    CXX := g++
endif
RSLT = ${foreach PARAM,$(_BP),$(call BPARAMS,$($(PARAM)),$(glibmm_),$(patsubst _%,%,$(PARAM)))}
# eliminate
${warning BPARAMS returns ${RSLT}}
# //
PCLOL := -L/usr/lib/i386-linux-gnu
BP  = $(PCLOL) $(PCLOl) $(PCCOO)

# CFLAGS += "$(HD_PPINCL)" "$(HD_PPDEFS)" "$(PCCOO)" "$(HD_PPFLAGS)"

# PCLOL = $(call _fpc_get,$(glibmm_),$(_PCLOL))
ifeq ($(findstring -L,$(call _fLDf)),NO_LD_L)
  ${warning LDFLAGS from pkgconfig are questionable! No -L<dirs> for linker: $(call _fLDf)}
  PCLOL ?= $(addprefix -L,$(call _f_bnks,/usr/lib/i386-linux-gnu))
endif

LDFLAGS += $(foreach YU,$(PCLOL),$(call f_QuoteMe,$(YU)))
DI := $(call f_SplitDict,$(strip $(_penum_)))

ifneq ($(_CODEF),$(f_Null))
   vpath %.cc $(dir $(_CODEF))
   vpath %.o  $(addsuffix /build,$(CURDIR))
 ifeq "$(findstr $(_CODEF),$(PROGRAM_FILES))" "$(_CODEF)"
  PROGRAM_FILES = $(_CODEF)
 endif
endif

# @echo ${@}:$(warning dict created is $(DI))

prebuild: pkgconfigx echoparams
	@>/dev/stderr $(pf) "$(COLR6)%s$(COLRsgr0)$(COLR7) found, vpath set to $(COLR2)%s$(COLRsgr0)$(COLR7)\n\n" \
   "$(notdir $(_CODEF))" "$(dir $(_CODEF))"

echoparams:
	@for zod in $(subst |,$(_fOneSpace),$(DI)); do >/dev/stderr $(pf) \
 "%s $(COLR1)"'%-8s: Param: %s$(COLRsgr0)\n' \
 "$(CXX)" COMPILE "$$zod"; done
	@for zed in $(strip $(BP) $(LDFLAGS)); do >/dev/stderr $(pf) \
 "%s $(COLR1)"'%-8s: Param: %s$(COLRsgr0)\n' \
 "$(CXX)" LINK "$$zed"; done
	@$(pf) " $(COLRsgr0)$(COLR7)"

testclr:
	@$(pf) "Testing colors:\n"
	@${foreach T,0 1 2 3 4 5 6 7,$(pf) "$(COLR7)IN $(COLR${T})COLOR  $(COLRsgr0)$(COLR7)";}

object: $(PROGRAM_FILES) prebuild $(_CODEF:%.cc=%.o) $(eval OF = $$(addprefix build/,$$(notdir $(_CODEF:%.cc=%.o))))
	@>/dev/stderr $(pf) 'Target $(COLR3)%s$(COLRsgr0) $(COLR7): Dependency on $(COLR3)%s$(COLRsgr0)$(COLR7) fulfilled.\n\n' '$@' '$<'

# Overrides implicit rule that GNU Make uses to build from C++ source files:
%.o : %.cc
	@>/dev/stderr $(pf) "Depends on %s\n" '${^}'
	@>/dev/stderr $(pf) "Building $(COLR3)%-13s$(COLRsgr0)$(COLR7) from $(COLR6)%s$(COLRsgr0)$(COLR7):\n" \
  '$(foreach CFOO,${@}, $(addprefix build/,$(call notdir,$(CFOO))))' '$^'
	$(call assCtoO,$@,$(if $^,$^,NOFILE))

$(PROGRAM): object
all: LIBS = $(BP)
all: object
	@>/dev/stderr $(pf) $(LONGLINE)
	@$(pf) "$(COLR2)$(CXX) -o $(COLR3)$(PROGRAM) $(COLRsgr0)$(COLR7) \\n\\t%s %s\n" '$(LDFLAGS) $(LIBS)' '$(OF)'
	>/dev/stdout $(CXX) -o $(PROGRAM) $(LDFLAGS) $(LIBS) $(OF)

clean: oclean
	@rm -rf $(PROGRAM)
oclean:
	rm -f $(addprefix build/,$(foreach VEH,$(_CODEF:%.cc=%.o),$(call notdir,$(VEH))))

zipmi:

define IGNORETHIS
#  pkg-config flags
#     --libs-only-l                           output -l flags
      --libs-only-other                       output other libs (e.g. -pthread)
      --libs-only-L                           output -L flags
      --cflags                                output all pre-processor and compiler flags
      --cflags-only-I                         output -I flags
      --cflags-only-other
endef

.PHONY: zipme clean oclean all \
  object build \
	testclr \
  pkgconfigcheck pkgconfigx prebuild
